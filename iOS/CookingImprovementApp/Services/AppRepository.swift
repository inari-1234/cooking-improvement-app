#if canImport(SwiftData)
import Foundation
import SwiftData

@MainActor
struct AppRepository {
    let context: ModelContext

    func createDish(name rawName: String) throws -> DishModel {
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw AppRepositoryError.emptyDishName }
        let dish = DishModel(name: name)
        context.insert(dish)
        do {
            try context.save()
            return dish
        } catch {
            context.rollback()
            throw error
        }
    }

    func createRecipe(
        dishID: UUID,
        yieldText rawYield: String,
        ingredients rawIngredients: [String],
        steps rawSteps: [String]
    ) throws -> RecipeVersionModel {
        let allTracks = try context.fetch(FetchDescriptor<RecipeTrackModel>())
        let activeTracks = allTracks.filter { $0.dishID == dishID && !$0.isArchived }
        let track: RecipeTrackModel
        if activeTracks.isEmpty {
            let anyTracks = allTracks.contains { $0.dishID == dishID }
            guard !anyTracks else { throw AppRepositoryError.archivedTracksRequireChoice }
            track = RecipeTrackModel(dishID: dishID, name: "標準")
            context.insert(track)
        } else if activeTracks.count == 1 {
            track = activeTracks[0]
        } else {
            throw AppRepositoryError.trackSelectionRequired
        }

        let allVersions = try context.fetch(FetchDescriptor<RecipeVersionModel>())
        let versions = allVersions.filter { $0.trackID == track.id }
        let nextNumber = (versions.map(\.versionNumber).max() ?? 0) + 1
        let yieldText = rawYield.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "2人前" : rawYield.trimmingCharacters(in: .whitespacesAndNewlines)
        let version = RecipeVersionModel(trackID: track.id, versionNumber: nextNumber, yieldText: yieldText)
        context.insert(version)

        let ingredients = rawIngredients.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        for (index, line) in ingredients.enumerated() {
            let parts = line.split(separator: " ", maxSplits: 1).map(String.init)
            let model = IngredientLineModel(
                recipeVersionID: version.id,
                name: parts.first ?? line,
                amountText: parts.count > 1 ? parts[1] : "",
                displayOrder: index
            )
            context.insert(model)
        }

        let steps = rawSteps.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        for (index, action) in steps.enumerated() {
            context.insert(RecipeStepModel(recipeVersionID: version.id, action: action, displayOrder: index))
        }

        if versions.filter({ !$0.isArchived }).isEmpty {
            track.adoptedVersionID = version.id
            context.insert(DecisionLogModel(trackID: track.id, fromVersionID: nil, toVersionID: version.id))
        }
        do {
            try context.save()
            return version
        } catch {
            context.rollback()
            throw error
        }
    }

    func startCooking(versionID: UUID) throws -> CookingSessionModel {
        let versions = try context.fetch(FetchDescriptor<RecipeVersionModel>())
        guard let version = versions.first(where: { $0.id == versionID && !$0.isArchived }) else {
            throw AppRepositoryError.versionUnavailable
        }
        let tracks = try context.fetch(FetchDescriptor<RecipeTrackModel>())
        guard let track = tracks.first(where: { $0.id == version.trackID && !$0.isArchived }) else {
            throw AppRepositoryError.trackUnavailable
        }
        let dishes = try context.fetch(FetchDescriptor<DishModel>())
        guard let dish = dishes.first(where: { $0.id == track.dishID && !$0.isArchived }) else {
            throw AppRepositoryError.dishUnavailable
        }
        _ = dish

        let steps = try context.fetch(FetchDescriptor<RecipeStepModel>())
            .filter { $0.recipeVersionID == version.id }
            .sorted { $0.displayOrder < $1.displayOrder }
        let session = CookingSessionModel(
            trackID: track.id,
            sourceRecipeVersionID: version.id,
            currentStepLineageID: steps.first?.lineageID
        )
        context.insert(session)
        do {
            try context.save()
            return session
        } catch {
            context.rollback()
            throw error
        }
    }

    func setCurrentStep(sessionID: UUID, lineageID: UUID?) throws {
        let sessions = try context.fetch(FetchDescriptor<CookingSessionModel>())
        guard let session = sessions.first(where: { $0.id == sessionID && $0.statusRaw == "inProgress" }) else {
            throw AppRepositoryError.sessionUnavailable
        }
        session.currentStepLineageID = lineageID
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func finishCooking(sessionID: UUID) throws {
        let sessions = try context.fetch(FetchDescriptor<CookingSessionModel>())
        guard let session = sessions.first(where: { $0.id == sessionID }) else { throw AppRepositoryError.sessionUnavailable }
        if session.statusRaw == "completed" { return }
        guard session.statusRaw == "inProgress" else { throw AppRepositoryError.sessionUnavailable }
        session.statusRaw = "completed"
        session.endedAt = .now
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

enum AppRepositoryError: Error, LocalizedError {
    case emptyDishName
    case archivedTracksRequireChoice
    case trackSelectionRequired
    case versionUnavailable
    case trackUnavailable
    case dishUnavailable
    case sessionUnavailable

    var errorDescription: String? {
        switch self {
        case .emptyDishName: "料理名を入力してください。"
        case .archivedTracksRequireChoice: "既存のレシピ系列がアーカイブされています。先に戻すか、新しい系列を作成してください。"
        case .trackSelectionRequired: "使用するレシピ系列を選択してください。"
        case .versionUnavailable: "このレシピは現在使用できません。"
        case .trackUnavailable: "このレシピ系列は現在使用できません。"
        case .dishUnavailable: "この料理は現在使用できません。"
        case .sessionUnavailable: "この調理セッションは現在変更できません。"
        }
    }
}
#endif

#if canImport(SwiftData)
import Foundation
import SwiftData

@Model final class DishModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var isFavorite: Bool
    var isArchived: Bool
    var createdAt: Date
    init(id: UUID = UUID(), name: String, isFavorite: Bool = false, isArchived: Bool = false, createdAt: Date = .now) {
        self.id = id; self.name = name; self.isFavorite = isFavorite; self.isArchived = isArchived; self.createdAt = createdAt
    }
}

@Model final class RecipeTrackModel {
    @Attribute(.unique) var id: UUID
    var dishID: UUID
    var name: String
    var isArchived: Bool
    var adoptedVersionID: UUID?
    init(id: UUID = UUID(), dishID: UUID, name: String = "標準", isArchived: Bool = false, adoptedVersionID: UUID? = nil) {
        self.id = id; self.dishID = dishID; self.name = name; self.isArchived = isArchived; self.adoptedVersionID = adoptedVersionID
    }
}

@Model final class DraftRecipeModel {
    @Attribute(.unique) var id: UUID
    var trackID: UUID
    var baseVersionID: UUID?
    var editRevision: Int
    var yieldText: String
    init(id: UUID = UUID(), trackID: UUID, baseVersionID: UUID? = nil, editRevision: Int = 1, yieldText: String = "2人前") {
        self.id = id; self.trackID = trackID; self.baseVersionID = baseVersionID; self.editRevision = editRevision; self.yieldText = yieldText
    }
}

@Model final class RecipeVersionModel {
    @Attribute(.unique) var id: UUID
    var trackID: UUID
    var versionNumber: Int
    var baseVersionID: UUID?
    var yieldText: String
    var isArchived: Bool
    var createdAt: Date
    init(id: UUID = UUID(), trackID: UUID, versionNumber: Int, baseVersionID: UUID? = nil, yieldText: String = "2人前", isArchived: Bool = false, createdAt: Date = .now) {
        self.id = id; self.trackID = trackID; self.versionNumber = versionNumber; self.baseVersionID = baseVersionID; self.yieldText = yieldText; self.isArchived = isArchived; self.createdAt = createdAt
    }
}

@Model final class IngredientLineModel {
    @Attribute(.unique) var id: UUID
    var recipeVersionID: UUID
    var lineageID: UUID
    var name: String
    var amountText: String
    var note: String?
    var sectionTitle: String?
    var sectionOrder: Int?
    var displayOrder: Int
    init(id: UUID = UUID(), recipeVersionID: UUID, lineageID: UUID = UUID(), name: String, amountText: String = "", note: String? = nil, sectionTitle: String? = nil, sectionOrder: Int? = nil, displayOrder: Int) {
        self.id = id; self.recipeVersionID = recipeVersionID; self.lineageID = lineageID; self.name = name; self.amountText = amountText; self.note = note; self.sectionTitle = sectionTitle; self.sectionOrder = sectionOrder; self.displayOrder = displayOrder
    }
}

@Model final class EquipmentUseModel {
    @Attribute(.unique) var id: UUID
    var recipeVersionID: UUID
    var lineageID: UUID
    var name: String
    var note: String?
    var displayOrder: Int
    init(id: UUID = UUID(), recipeVersionID: UUID, lineageID: UUID = UUID(), name: String, note: String? = nil, displayOrder: Int) {
        self.id = id; self.recipeVersionID = recipeVersionID; self.lineageID = lineageID; self.name = name; self.note = note; self.displayOrder = displayOrder
    }
}

@Model final class KeyParameterModel {
    @Attribute(.unique) var id: UUID
    var recipeVersionID: UUID
    var lineageID: UUID
    var name: String
    var valueText: String
    var note: String?
    var displayOrder: Int
    init(id: UUID = UUID(), recipeVersionID: UUID, lineageID: UUID = UUID(), name: String, valueText: String, note: String? = nil, displayOrder: Int) {
        self.id = id; self.recipeVersionID = recipeVersionID; self.lineageID = lineageID; self.name = name; self.valueText = valueText; self.note = note; self.displayOrder = displayOrder
    }
}

@Model final class RecipeStepModel {
    @Attribute(.unique) var id: UUID
    var recipeVersionID: UUID
    var lineageID: UUID
    var action: String
    var note: String?
    var detail: String?
    var timerSeconds: Int?
    var heat: String?
    var sectionTitle: String?
    var sectionOrder: Int?
    var displayOrder: Int
    init(id: UUID = UUID(), recipeVersionID: UUID, lineageID: UUID = UUID(), action: String, note: String? = nil, detail: String? = nil, timerSeconds: Int? = nil, heat: String? = nil, sectionTitle: String? = nil, sectionOrder: Int? = nil, displayOrder: Int) {
        self.id = id; self.recipeVersionID = recipeVersionID; self.lineageID = lineageID; self.action = action; self.note = note; self.detail = detail; self.timerSeconds = timerSeconds; self.heat = heat; self.sectionTitle = sectionTitle; self.sectionOrder = sectionOrder; self.displayOrder = displayOrder
    }
}

@Model final class CookingSessionModel {
    @Attribute(.unique) var id: UUID
    var trackID: UUID
    var sourceRecipeVersionID: UUID?
    var statusRaw: String
    var startedAt: Date
    var endedAt: Date?
    var revision: Int
    var currentStepLineageID: UUID?
    init(id: UUID = UUID(), trackID: UUID, sourceRecipeVersionID: UUID? = nil, statusRaw: String = "inProgress", startedAt: Date = .now, endedAt: Date? = nil, revision: Int = 1, currentStepLineageID: UUID? = nil) {
        self.id = id; self.trackID = trackID; self.sourceRecipeVersionID = sourceRecipeVersionID; self.statusRaw = statusRaw; self.startedAt = startedAt; self.endedAt = endedAt; self.revision = revision; self.currentStepLineageID = currentStepLineageID
    }
}

@Model final class EvaluationModel {
    @Attribute(.unique) var id: UUID
    var sessionID: UUID
    var gradeRaw: String
    var createdAt: Date
    init(id: UUID = UUID(), sessionID: UUID, gradeRaw: String, createdAt: Date = .now) { self.id = id; self.sessionID = sessionID; self.gradeRaw = gradeRaw; self.createdAt = createdAt }
}

@Model final class EvaluationObservationModel {
    @Attribute(.unique) var id: UUID
    var evaluationID: UUID
    var roleRaw: String
    var aspectName: String?
    var note: String?
    init(id: UUID = UUID(), evaluationID: UUID, roleRaw: String, aspectName: String? = nil, note: String? = nil) { self.id = id; self.evaluationID = evaluationID; self.roleRaw = roleRaw; self.aspectName = aspectName; self.note = note }
}

@Model final class CookingTimerModel {
    @Attribute(.unique) var id: UUID
    var sessionID: UUID
    var startedAt: Date
    var durationSeconds: Int
    var cancelledAt: Date?
    init(id: UUID = UUID(), sessionID: UUID, startedAt: Date = .now, durationSeconds: Int, cancelledAt: Date? = nil) { self.id = id; self.sessionID = sessionID; self.startedAt = startedAt; self.durationSeconds = durationSeconds; self.cancelledAt = cancelledAt }
}

@Model final class ExperimentIdeaModel {
    @Attribute(.unique) var id: UUID
    var trackID: UUID
    var conditionRevision: Int
    var purpose: String
    var isDismissed: Bool
    var dismissedAt: Date?
    init(id: UUID = UUID(), trackID: UUID, conditionRevision: Int = 1, purpose: String, isDismissed: Bool = false, dismissedAt: Date? = nil) { self.id = id; self.trackID = trackID; self.conditionRevision = conditionRevision; self.purpose = purpose; self.isDismissed = isDismissed; self.dismissedAt = dismissedAt }
}

@Model final class ExperimentAttemptModel {
    @Attribute(.unique) var id: UUID
    var experimentIdeaID: UUID
    var ideaConditionRevision: Int
    var sessionID: UUID
    var purposeSnapshot: String
    var plannedAt: Date
    init(id: UUID = UUID(), experimentIdeaID: UUID, ideaConditionRevision: Int, sessionID: UUID, purposeSnapshot: String, plannedAt: Date = .now) { self.id = id; self.experimentIdeaID = experimentIdeaID; self.ideaConditionRevision = ideaConditionRevision; self.sessionID = sessionID; self.purposeSnapshot = purposeSnapshot; self.plannedAt = plannedAt }
}

@Model final class CookingSessionCorrectionModel {
    @Attribute(.unique) var id: UUID
    var sessionID: UUID
    var fromRevision: Int
    var toRevision: Int
    var correctedAt: Date
    var reason: String?
    init(id: UUID = UUID(), sessionID: UUID, fromRevision: Int, toRevision: Int, correctedAt: Date = .now, reason: String? = nil) { self.id = id; self.sessionID = sessionID; self.fromRevision = fromRevision; self.toRevision = toRevision; self.correctedAt = correctedAt; self.reason = reason }
}

@Model final class CorrectionEntryModel {
    @Attribute(.unique) var id: UUID
    var correctionID: UUID
    var targetKey: String
    var beforePayload: String?
    var afterPayload: String?
    init(id: UUID = UUID(), correctionID: UUID, targetKey: String, beforePayload: String? = nil, afterPayload: String? = nil) { self.id = id; self.correctionID = correctionID; self.targetKey = targetKey; self.beforePayload = beforePayload; self.afterPayload = afterPayload }
}

@Model final class SessionRecipeMaterializationModel {
    @Attribute(.unique) var id: UUID
    var sessionID: UUID
    var sessionRevision: Int
    var recipeVersionID: UUID
    var resultKindRaw: String
    var createdAt: Date
    init(id: UUID = UUID(), sessionID: UUID, sessionRevision: Int, recipeVersionID: UUID, resultKindRaw: String, createdAt: Date = .now) { self.id = id; self.sessionID = sessionID; self.sessionRevision = sessionRevision; self.recipeVersionID = recipeVersionID; self.resultKindRaw = resultKindRaw; self.createdAt = createdAt }
}

@Model final class DecisionLogModel {
    @Attribute(.unique) var id: UUID
    var trackID: UUID
    var fromVersionID: UUID?
    var toVersionID: UUID
    var sourceSessionID: UUID?
    var sourceSessionRevision: Int?
    var evaluationGradeSnapshot: String?
    var reason: String?
    var createdAt: Date
    init(id: UUID = UUID(), trackID: UUID, fromVersionID: UUID? = nil, toVersionID: UUID, sourceSessionID: UUID? = nil, sourceSessionRevision: Int? = nil, evaluationGradeSnapshot: String? = nil, reason: String? = nil, createdAt: Date = .now) { self.id = id; self.trackID = trackID; self.fromVersionID = fromVersionID; self.toVersionID = toVersionID; self.sourceSessionID = sourceSessionID; self.sourceSessionRevision = sourceSessionRevision; self.evaluationGradeSnapshot = evaluationGradeSnapshot; self.reason = reason; self.createdAt = createdAt }
}

@Model final class SessionPhotoModel {
    @Attribute(.unique) var id: UUID
    var sessionID: UUID
    var relativePath: String
    var checksumSHA256: String
    var createdAt: Date
    init(id: UUID = UUID(), sessionID: UUID, relativePath: String, checksumSHA256: String, createdAt: Date = .now) { self.id = id; self.sessionID = sessionID; self.relativePath = relativePath; self.checksumSHA256 = checksumSHA256; self.createdAt = createdAt }
}

// Explicit child models used by the full V1 mapper. They intentionally avoid opaque Data/transformable blobs.
@Model final class RecipeContentModel { @Attribute(.unique) var id: UUID; var ownerID: UUID; var ownerKindRaw: String; var yieldText: String; init(id: UUID = UUID(), ownerID: UUID, ownerKindRaw: String, yieldText: String) { self.id = id; self.ownerID = ownerID; self.ownerKindRaw = ownerKindRaw; self.yieldText = yieldText } }
@Model final class MeasurementModel { @Attribute(.unique) var id: UUID; var ownerID: UUID; var kindRaw: String; var mantissa: Int64?; var scale: Int?; var lowerMantissa: Int64?; var lowerScale: Int?; var upperMantissa: Int64?; var upperScale: Int?; var textValue: String?; var unit: String?; init(id: UUID = UUID(), ownerID: UUID, kindRaw: String) { self.id = id; self.ownerID = ownerID; self.kindRaw = kindRaw } }
@Model final class RecipeChangeModel { @Attribute(.unique) var id: UUID; var ownerID: UUID; var targetKindRaw: String; var recordKindRaw: String?; var lineageID: UUID?; var fieldRaw: String?; var operationRaw: String; init(id: UUID = UUID(), ownerID: UUID, targetKindRaw: String, operationRaw: String) { self.id = id; self.ownerID = ownerID; self.targetKindRaw = targetKindRaw; self.operationRaw = operationRaw } }
@Model final class ChangePayloadModel { @Attribute(.unique) var id: UUID; var changeID: UUID; var sideRaw: String; var stringValue: String?; var intValue: Int?; init(id: UUID = UUID(), changeID: UUID, sideRaw: String) { self.id = id; self.changeID = changeID; self.sideRaw = sideRaw } }
@Model final class RecordSnapshotModel { @Attribute(.unique) var id: UUID; var payloadID: UUID; var recordKindRaw: String; var lineageID: UUID; var nameOrAction: String; var displayOrder: Int; init(id: UUID = UUID(), payloadID: UUID, recordKindRaw: String, lineageID: UUID, nameOrAction: String, displayOrder: Int) { self.id = id; self.payloadID = payloadID; self.recordKindRaw = recordKindRaw; self.lineageID = lineageID; self.nameOrAction = nameOrAction; self.displayOrder = displayOrder } }

struct VersionedSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(1, 0, 0) }
    static var models: [any PersistentModel.Type] {
        [DishModel.self, RecipeTrackModel.self, DraftRecipeModel.self, RecipeVersionModel.self,
         IngredientLineModel.self, EquipmentUseModel.self, KeyParameterModel.self, RecipeStepModel.self,
         CookingSessionModel.self, EvaluationModel.self, EvaluationObservationModel.self, CookingTimerModel.self,
         ExperimentIdeaModel.self, ExperimentAttemptModel.self, CookingSessionCorrectionModel.self, CorrectionEntryModel.self,
         SessionRecipeMaterializationModel.self, DecisionLogModel.self, SessionPhotoModel.self, RecipeContentModel.self, MeasurementModel.self,
         RecipeChangeModel.self, ChangePayloadModel.self, RecordSnapshotModel.self]
    }
}

enum SwiftDataContainerFactoryV1 {
    static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: VersionedSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, migrationPlan: nil, configurations: [configuration])
    }

    static func make(storeURL: URL) throws -> ModelContainer {
        let schema = Schema(versionedSchema: VersionedSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, url: storeURL)
        return try ModelContainer(for: schema, migrationPlan: nil, configurations: [configuration])
    }
}
#endif

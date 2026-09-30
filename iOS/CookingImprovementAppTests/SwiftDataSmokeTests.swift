import XCTest
import SwiftData
@testable import CookingImprovementApp

@MainActor
final class SwiftDataSmokeTests: XCTestCase {
    func testInMemoryContainerSavesAndRefetchesCoreRows() throws {
        let container = try SwiftDataContainerFactoryV1.make(inMemory: true)
        let context = container.mainContext

        let dish = DishModel(name: "レモンパスタ")
        let track = RecipeTrackModel(dishID: dish.id, name: "標準")
        let version = RecipeVersionModel(trackID: track.id, versionNumber: 1, yieldText: "2人前")
        track.adoptedVersionID = version.id
        let recipeContent = RecipeContentModel(
            ownerID: version.id,
            ownerKindRaw: "recipeVersion",
            yieldText: "2人前"
        )
        let ingredient = IngredientLineModel(recipeVersionID: version.id, name: "レモン", amountText: "1個", displayOrder: 0)
        let measurement = MeasurementModel(ownerID: ingredient.id, kindRaw: "exact")
        measurement.mantissa = 1
        measurement.scale = 0
        measurement.unit = "個"
        let step = RecipeStepModel(recipeVersionID: version.id, action: "レモンを絞る", displayOrder: 0)
        let session = CookingSessionModel(trackID: track.id, sourceRecipeVersionID: version.id, currentStepLineageID: step.lineageID)

        context.insert(dish)
        context.insert(track)
        context.insert(version)
        context.insert(recipeContent)
        context.insert(ingredient)
        context.insert(measurement)
        context.insert(step)
        context.insert(session)
        try context.save()

        XCTAssertEqual(try context.fetch(FetchDescriptor<DishModel>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<RecipeTrackModel>()).first?.adoptedVersionID, version.id)
        XCTAssertEqual(try context.fetch(FetchDescriptor<RecipeVersionModel>()).first?.versionNumber, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<RecipeContentModel>()).first?.yieldText, "2人前")
        XCTAssertEqual(try context.fetch(FetchDescriptor<IngredientLineModel>()).first?.name, "レモン")
        XCTAssertEqual(try context.fetch(FetchDescriptor<MeasurementModel>()).first?.mantissa, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<MeasurementModel>()).first?.unit, "個")
        XCTAssertEqual(try context.fetch(FetchDescriptor<RecipeStepModel>()).first?.lineageID, step.lineageID)
        XCTAssertEqual(try context.fetch(FetchDescriptor<CookingSessionModel>()).first?.statusRaw, "inProgress")
    }

    func testFileStoreSurvivesContainerReopen() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CookingImprovementAppTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appendingPathComponent("CookingImprovement.store")
        let dishID = UUID()

        do {
            let container = try SwiftDataContainerFactoryV1.make(storeURL: storeURL)
            let context = container.mainContext
            context.insert(DishModel(id: dishID, name: "味噌ラーメン"))
            try context.save()
        }

        do {
            let reopened = try SwiftDataContainerFactoryV1.make(storeURL: storeURL)
            let context = reopened.mainContext
            let dishes = try context.fetch(FetchDescriptor<DishModel>())
            XCTAssertEqual(dishes.count, 1)
            XCTAssertEqual(dishes.first?.id, dishID)
            XCTAssertEqual(dishes.first?.name, "味噌ラーメン")
        }
    }

    func testRepositoryMinimumFlowPersistsSession() throws {
        let container = try SwiftDataContainerFactoryV1.make(inMemory: true)
        let context = container.mainContext
        let repository = AppRepository(context: context)

        let dish = try repository.createDish(name: "コーヒー")
        let version = try repository.createRecipe(
            dishID: dish.id,
            yieldText: "1杯",
            ingredients: ["コーヒー豆 10g", "湯 260g"],
            steps: ["豆を挽く", "抽出する"]
        )
        let session = try repository.startCooking(versionID: version.id)
        try repository.finishCooking(sessionID: session.id)

        let sessions = try context.fetch(FetchDescriptor<CookingSessionModel>())
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.statusRaw, "completed")
        XCTAssertNotNil(sessions.first?.endedAt)
    }
}

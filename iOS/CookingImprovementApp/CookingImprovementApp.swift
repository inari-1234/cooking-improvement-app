#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData

@main
struct CookingImprovementApp: App {
    private let container: ModelContainer = {
        do { return try SwiftDataContainerFactoryV1.make() }
        catch { fatalError("SwiftData container initialization failed: \(error)") }
    }()

    var body: some Scene {
        WindowGroup { HomeView() }
            .modelContainer(container)
    }
}
#endif

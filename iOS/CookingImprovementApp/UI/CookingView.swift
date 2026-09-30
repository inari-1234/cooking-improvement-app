#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData

struct CookingView: View {
    let session: CookingSessionModel
    let version: RecipeVersionModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var allSteps: [RecipeStepModel]
    @State private var errorMessage: String?

    private var steps: [RecipeStepModel] {
        allSteps.filter { $0.recipeVersionID == version.id }.sorted { $0.displayOrder < $1.displayOrder }
    }
    private var currentIndex: Int {
        guard let id = session.currentStepLineageID, let i = steps.firstIndex(where: { $0.lineageID == id }) else { return 0 }
        return i
    }

    var body: some View {
        VStack(spacing: 24) {
            if steps.isEmpty {
                ContentUnavailableView("工程がありません", systemImage: "list.number")
            } else {
                Text("工程 \(currentIndex + 1) / \(steps.count)")
                    .font(.subheadline).foregroundStyle(.secondary)
                Text(steps[currentIndex].action)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding()
                HStack {
                    Button("前へ") { move(to: max(0, currentIndex - 1)) }
                        .buttonStyle(.bordered)
                        .disabled(currentIndex == 0)
                    Spacer()
                    if currentIndex + 1 < steps.count {
                        Button("次へ") { move(to: currentIndex + 1) }
                            .buttonStyle(.borderedProminent)
                    } else {
                        Button("調理を完了") { finish() }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            if let errorMessage { Text(errorMessage).foregroundStyle(.red) }
            Spacer()
        }
        .padding()
        .navigationTitle("調理中")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func move(to index: Int) {
        guard steps.indices.contains(index) else { return }
        do { try AppRepository(context: context).setCurrentStep(sessionID: session.id, lineageID: steps[index].lineageID) }
        catch { errorMessage = error.localizedDescription }
    }

    private func finish() {
        do {
            try AppRepository(context: context).finishCooking(sessionID: session.id)
            dismiss()
        } catch { errorMessage = error.localizedDescription }
    }
}
#endif

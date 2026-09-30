#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData

struct AddRecipeSheet: View {
    let dishID: UUID
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var yieldText = "2人前"
    @State private var ingredientText = ""
    @State private var stepText = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("分量") { TextField("2人前", text: $yieldText) }
                Section("材料") {
                    TextEditor(text: $ingredientText).frame(minHeight: 120)
                    Text("1行に1つ。例：レモン 1個").font(.caption).foregroundStyle(.secondary)
                }
                Section("作り方") {
                    TextEditor(text: $stepText).frame(minHeight: 150)
                    Text("1行に1工程を入力します。").font(.caption).foregroundStyle(.secondary)
                }
                if let errorMessage { Text(errorMessage).foregroundStyle(.red) }
            }
            .navigationTitle("作り方を登録")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("キャンセル") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("保存") { save() } }
            }
        }
    }

    private func save() {
        do {
            _ = try AppRepository(context: context).createRecipe(
                dishID: dishID,
                yieldText: yieldText,
                ingredients: ingredientText.components(separatedBy: .newlines),
                steps: stepText.components(separatedBy: .newlines)
            )
            dismiss()
        } catch { errorMessage = error.localizedDescription }
    }
}
#endif

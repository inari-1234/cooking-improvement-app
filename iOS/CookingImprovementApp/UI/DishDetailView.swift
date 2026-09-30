#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData

struct DishDetailView: View {
    let dish: DishModel
    @Environment(\.modelContext) private var context
    @Query private var tracks: [RecipeTrackModel]
    @Query private var versions: [RecipeVersionModel]
    @Query private var ingredients: [IngredientLineModel]
    @Query private var steps: [RecipeStepModel]
    @State private var showingRecipe = false
    @State private var navigationRoute: CookingRoute?
    @Query private var sessions: [CookingSessionModel]
    @State private var errorMessage: String?

    private var dishTracks: [RecipeTrackModel] { tracks.filter { $0.dishID == dish.id && !$0.isArchived } }
    private var adoptedVersion: RecipeVersionModel? {
        for track in dishTracks {
            if let id = track.adoptedVersionID, let v = versions.first(where: { $0.id == id && !$0.isArchived }) { return v }
        }
        return nil
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text(dish.name).font(.title2.bold())
                    if let version = adoptedVersion {
                        Text("現在の作り方").font(.caption).foregroundStyle(.secondary)
                        Text(version.yieldText).font(.headline)
                        Button("作る") { start(version) }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                    } else {
                        Text("まだ作り方が登録されていません。")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            if let version = adoptedVersion {
                Section("材料") {
                    let rows = ingredients.filter { $0.recipeVersionID == version.id }.sorted { $0.displayOrder < $1.displayOrder }
                    if rows.isEmpty { Text("材料なし").foregroundStyle(.secondary) }
                    ForEach(rows) { row in
                        HStack { Text(row.name); Spacer(); Text(row.amountText).foregroundStyle(.secondary) }
                    }
                }
                Section("作り方") {
                    let rows = steps.filter { $0.recipeVersionID == version.id }.sorted { $0.displayOrder < $1.displayOrder }
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                        HStack(alignment: .top) { Text("\(index + 1)").foregroundStyle(.secondary); Text(row.action) }
                    }
                }
            }

            if let errorMessage { Section { Text(errorMessage).foregroundStyle(.red) } }
        }
        .navigationTitle(dish.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(adoptedVersion == nil ? "作り方を登録" : "新しい版") { showingRecipe = true }
            }
        }
        .sheet(isPresented: $showingRecipe) { AddRecipeSheet(dishID: dish.id) }
        .navigationDestination(item: $navigationRoute) { route in
            if let session = sessions.first(where: { $0.id == route.sessionID }),
               let version = versions.first(where: { $0.id == route.versionID }) {
                CookingView(session: session, version: version)
            } else {
                ContentUnavailableView("調理データを開けません", systemImage: "exclamationmark.triangle")
            }
        }
    }

    private func start(_ version: RecipeVersionModel) {
        do { let session = try AppRepository(context: context).startCooking(versionID: version.id)
            navigationRoute = CookingRoute(sessionID: session.id, versionID: version.id) }
        catch { errorMessage = error.localizedDescription }
    }
}

private struct CookingRoute: Identifiable, Hashable {
    let sessionID: UUID
    let versionID: UUID
    var id: UUID { sessionID }
}
#endif

#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DishModel.createdAt, order: .reverse) private var dishes: [DishModel]
    @Query private var sessions: [CookingSessionModel]
    @Query private var tracks: [RecipeTrackModel]
    @Query private var versions: [RecipeVersionModel]
    @State private var showingAddDish = false

    private var activeSessions: [CookingSessionModel] {
        sessions.filter { $0.statusRaw == "inProgress" }.sorted { $0.startedAt > $1.startedAt }
    }

    var body: some View {
        NavigationStack {
            List {
                if !activeSessions.isEmpty {
                    Section("調理中") {
                        ForEach(activeSessions) { session in
                            if let version = versions.first(where: { $0.id == session.sourceRecipeVersionID }) {
                                NavigationLink {
                                    CookingView(session: session, version: version)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(dishName(for: session) ?? "調理中")
                                            .font(.headline)
                                        Text("続きから")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("すべての料理") {
                    if dishes.filter({ !$0.isArchived }).isEmpty {
                        ContentUnavailableView("料理がありません", systemImage: "fork.knife", description: Text("＋から最初の料理を登録してください。"))
                    } else {
                        ForEach(dishes.filter { !$0.isArchived }) { dish in
                            NavigationLink(dish.name) { DishDetailView(dish: dish) }
                        }
                    }
                }
            }
            .navigationTitle("料理改善")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddDish = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("料理を追加")
                }
            }
            .sheet(isPresented: $showingAddDish) { AddDishSheet() }
        }
    }

    private func dishName(for session: CookingSessionModel) -> String? {
        guard let track = tracks.first(where: { $0.id == session.trackID }) else { return nil }
        return dishes.first(where: { $0.id == track.dishID })?.name
    }
}
#endif

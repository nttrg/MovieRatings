import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            MovieListView()
                .tabItem {
                    Label("Фильмы", systemImage: "film")
                }

            RatedView()
                .tabItem {
                    Label("Оценки", systemImage: "star.fill")
                }

            FavoritesView()
                .tabItem {
                    Label("Избранное", systemImage: "heart.fill")
                }
        }
        .tint(Theme.accent)
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: Movie.self, inMemory: true)
}

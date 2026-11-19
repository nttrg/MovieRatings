import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate<Movie> { $0.isFavorite == true },
        sort: \Movie.title
    ) private var favorites: [Movie]
    
    @State private var randomMovie: Movie?
    @State private var showRandomAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "Нет избранных",
                        systemImage: "heart",
                        description: Text("Добавьте фильмы в избранное, чтобы они появились здесь")
                    )
                } else {
                    List {
                        // Кнопка рулетки, если есть что выбирать
                        if favorites.contains(where: { $0.userRating == nil }) {
                            Section {
                                Button {
                                    pickRandomMovie()
                                } label: {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "dice")
                                        Text("Что посмотреть?")
                                            .fontWeight(.bold)
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Theme.accent)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                            }
                        }

                        ForEach(favorites) { movie in
                            NavigationLink(value: movie.id) {
                                MovieRowView(movie: movie)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let movie = favorites[index]
                                movie.isFavorite = false
                            }
                            try? modelContext.save()
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Избранное")
            .navigationDestination(for: Int.self) { movieId in
                MovieDetailView(movieId: movieId)
            }
            // Модалка с результатом рулетки
            .sheet(item: $randomMovie) { movie in
                RandomMovieSheet(movie: movie)
                    .presentationDetents([.fraction(0.4)])
            }
        }
    }
    
    private func pickRandomMovie() {
        let unrated = favorites.filter { $0.userRating == nil }
        if let picked = unrated.randomElement() {
            randomMovie = picked
        }
    }
}

// Выносим модальное окно в отдельную структуру для чистоты
struct RandomMovieSheet: View {
    @Environment(\.dismiss) private var dismiss
    let movie: Movie
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Сегодня смотрим:")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(movie.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(String(movie.releaseDate.prefix(4)))
                    .foregroundStyle(.secondary)
                
                NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                    Text("Перейти к фильму")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                .padding(.horizontal)
            }
            .padding(.top, 30)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }
}

// Нужно для использования .sheet(item:)
extension Movie: Identifiable {}

#Preview {
    FavoritesView()
        .modelContainer(for: Movie.self, inMemory: true)
}

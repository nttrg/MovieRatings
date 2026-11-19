import SwiftUI
import SwiftData

struct RatedView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate<Movie> { $0.userRating != nil },
        sort: \Movie.title
    ) private var ratedMovies: [Movie]

    var body: some View {
        NavigationStack {
            Group {
                if ratedMovies.isEmpty {
                    ContentUnavailableView(
                        "Нет оценок",
                        systemImage: "star",
                        description: Text("Поставьте оценку фильму, и он появится здесь")
                    )
                } else {
                    List {
                        ForEach(ratedMovies) { movie in
                            NavigationLink(value: movie.id) {
                                MovieRowView(movie: movie)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Оценки")
            .navigationDestination(for: Int.self) { movieId in
                MovieDetailView(movieId: movieId)
            }
        }
    }
}

#Preview {
    RatedView()
        .modelContainer(for: Movie.self, inMemory: true)
}

import SwiftUI
import SwiftData

struct MovieListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Movie.title) private var allMovies: [Movie]

    @State private var viewModel: MovieListViewModel?

    @State private var searchText = ""
    @State private var showAdmin = false

    var filteredMovies: [Movie] {
        var list = allMovies

        if viewModel?.showOnlyRated == true {
            list = list.filter { $0.userRating != nil }
        }

        if !searchText.isEmpty {
            list = list.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        return list
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredMovies) { movie in
                    NavigationLink(value: movie.id) {
                        MovieRowView(movie: movie)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            viewModel?.toggleFavorite(movie)
                        } label: {
                            Label(
                                movie.isFavorite ? "Убрать" : "В избранное",
                                systemImage: movie.isFavorite ? "heart.slash" : "heart"
                            )
                        }
                        .tint(.pink)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        viewModel?.deleteMovie(filteredMovies[index])
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Фильмы")
            .searchable(text: $searchText, prompt: "Поиск")
            .onSubmit(of: .search) {
                viewModel?.searchText = searchText
                Task { await viewModel?.searchOnServer() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task { await viewModel?.loadMoviesFromAPI() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel?.isLoading == true)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            viewModel?.toggleShowOnlyRated()
                        } label: {
                            Image(systemName: viewModel?.showOnlyRated == true ? "star.fill" : "star")
                        }

                        Button("Админ") {
                            showAdmin = true
                        }
                    }
                }
            }
            .navigationDestination(for: Int.self) { movieId in
                MovieDetailView(movieId: movieId)
            }
            .sheet(isPresented: $showAdmin) {
                AdminView()
            }
            .overlay {
                if viewModel?.isLoading == true {
                    ProgressView("Загрузка...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(Theme.cornerRadius)
                }
            }
            .alert("Ошибка", isPresented: Binding(
                get: { viewModel?.errorMessage != nil },
                set: { if !$0 { viewModel?.errorMessage = nil } }
            )) {
                Button("Повторить") {
                    Task { await viewModel?.loadMoviesFromAPI() }
                }
                Button("Отмена", role: .cancel) { }
            } message: {
                Text(viewModel?.errorMessage ?? "")
            }
        }
        .task {
            if viewModel == nil {
                viewModel = MovieListViewModel(modelContext: modelContext)
                await viewModel?.loadMoviesFromAPI()
            }
        }
    }
}

#Preview {
    MovieListView()
        .modelContainer(for: Movie.self, inMemory: true)
}

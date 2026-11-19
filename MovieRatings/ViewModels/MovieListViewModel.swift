import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class MovieListViewModel {
    var searchText = ""
    var showOnlyRated = false
    var isLoading = false
    var errorMessage: String?

    private let modelContext: ModelContext
    private let api: MovieAPIServiceProtocol

    init(modelContext: ModelContext, api: MovieAPIServiceProtocol = MovieAPIService()) {
        self.modelContext = modelContext
        self.api = api
        self.showOnlyRated = UserDefaults.standard.bool(forKey: "showOnlyRated")
    }

    func loadMoviesFromAPI() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let dtos = try await api.fetchPopularMovies(page: 1)
            insertNew(dtos)
        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
        }
    }

    func searchOnServer() async {
        guard !searchText.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let dtos = try await api.searchMovies(query: searchText)
            insertNew(dtos)
        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
        }
    }

    func deleteMovie(_ movie: Movie) {
        modelContext.delete(movie)
        try? modelContext.save()
    }

    func toggleFavorite(_ movie: Movie) {
        movie.isFavorite.toggle()
        try? modelContext.save()
    }

    func toggleShowOnlyRated() {
        showOnlyRated.toggle()
        UserDefaults.standard.set(showOnlyRated, forKey: "showOnlyRated")
    }

    private func insertNew(_ dtos: [MovieDTO]) {
        for dto in dtos where !exists(id: dto.id) {
            modelContext.insert(dto.toMovie())
        }
        try? modelContext.save()
    }

    private func exists(id: Int) -> Bool {
        let descriptor = FetchDescriptor<Movie>(predicate: #Predicate { $0.id == id })
        return ((try? modelContext.fetchCount(descriptor)) ?? 0) > 0
    }
}

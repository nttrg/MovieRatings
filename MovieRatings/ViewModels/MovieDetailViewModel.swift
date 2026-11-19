import Foundation
import SwiftData

@MainActor
@Observable
final class MovieDetailViewModel {
    var userRating: Double = 0
    var isSending = false
    var postError: String?
    var postSuccess = false

    private let movieId: Int
    private let modelContext: ModelContext
    private let api: MovieAPIServiceProtocol

    init(movieId: Int, modelContext: ModelContext, api: MovieAPIServiceProtocol = MovieAPIService()) {
        self.movieId = movieId
        self.modelContext = modelContext
        self.api = api
    }

    func saveRating(for movie: Movie) {
        userRating = max(0, min(10, userRating))
        Task { await performSave(movie: movie, rating: userRating > 0 ? userRating : nil) }
    }

    func removeRating(for movie: Movie) {
        Task { await performSave(movie: movie, rating: nil) }
    }

    func toggleFavorite(_ movie: Movie) {
        movie.isFavorite.toggle()
        try? modelContext.save()
    }

    // MARK: - Private

    private func performSave(movie: Movie, rating: Double?) async {
        isSending = true
        postError = nil
        postSuccess = false

        movie.userRating = rating
        do {
            try modelContext.save()
        } catch {
            isSending = false
            postError = "Не удалось сохранить оценку локально"
            return
        }

        guard let rating else {
            isSending = false
            postSuccess = true
            return
        }

        do {
            try await api.postRating(movieId: movieId, title: movie.title, rating: rating)
            postSuccess = true
            postError = nil
        } catch let error as NetworkError {
            postSuccess = true
            postError = "Сохранено на устройстве. \(error.errorDescription ?? "Сервер недоступен.")"
        } catch {
            postSuccess = true
            postError = "Сохранено на устройстве. Сервер недоступен."
        }
        isSending = false
    }
}

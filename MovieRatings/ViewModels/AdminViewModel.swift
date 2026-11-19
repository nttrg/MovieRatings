import Foundation

@MainActor
@Observable
final class AdminViewModel {
    var isLoading = false
    var testMessage: String = ""
    
    // Ссылка на логгер для UI
    var logger: NetworkLogger { NetworkLogger.shared }

    private let api: MovieAPIServiceProtocol

    init(api: MovieAPIServiceProtocol = MovieAPIService()) {
        self.api = api
    }

    func testGET() async {
        isLoading = true
        testMessage = "Выполняется GET..."
        defer { isLoading = false }

        do {
            let movies = try await api.fetchPopularMovies(page: 1)
            testMessage = "GET OK: получено \(movies.count) фильмов"
        } catch {
            testMessage = "GET FAIL: \((error as? NetworkError)?.errorDescription ?? error.localizedDescription)"
        }
    }

    func testPOST() async {
        isLoading = true
        testMessage = "Выполняется POST..."
        defer { isLoading = false }

        do {
            try await api.postRating(movieId: 1, title: "Test Movie", rating: 8.5)
            testMessage = "POST OK: оценка отправлена"
        } catch {
            testMessage = "POST FAIL: \((error as? NetworkError)?.errorDescription ?? error.localizedDescription)"
        }
    }

    func clearLogs() {
        logger.clear()
        testMessage = ""
    }
}

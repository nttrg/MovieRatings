import Foundation

protocol MovieAPIServiceProtocol {
    func fetchPopularMovies(page: Int) async throws -> [MovieDTO]
    func searchMovies(query: String) async throws -> [MovieDTO]
    func postRating(movieId: Int, title: String, rating: Double) async throws
}

final class MovieAPIService: MovieAPIServiceProtocol {

    private let apiKey: String
    private let baseURL = "https://api.themoviedb.org/3"
    
    // ИСПРАВЛЕНИЕ: убрали прямую инициализацию логгера, чтобы не было ошибки Swift 6
    private var logger: NetworkLogger {
        get async { await NetworkLogger.shared }
    }

    private let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 25
        config.timeoutIntervalForResource = 40
        return URLSession(configuration: config)
    }()

    init(apiKey: String = AppConfig.tmdbAPIKey) {
        self.apiKey = apiKey
    }

    // MARK: - GET

    func fetchPopularMovies(page: Int = 1) async throws -> [MovieDTO] {
        try await get(
            path: "/movie/popular",
            query: [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "language", value: "ru-RU"),
                URLQueryItem(name: "page", value: String(page))
            ]
        )
    }

    func searchMovies(query: String) async throws -> [MovieDTO] {
        try await get(
            path: "/search/movie",
            query: [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "language", value: "ru-RU"),
                URLQueryItem(name: "query", value: query)
            ]
        )
    }

    private func get(path: String, query: [URLQueryItem]) async throws -> [MovieDTO] {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = query
        guard let url = components?.url else {
            await logGETFailure(NetworkError.invalidURL)
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)
            try validate(response)

            let decoded = try JSONDecoder().decode(MoviesResponse.self, from: data)
            await logGETSuccess(count: decoded.results.count)
            return decoded.results
        } catch let error as NetworkError {
            await logGETFailure(error)
            throw error
        } catch is DecodingError {
            await logGETFailure(.decodingFailed)
            throw NetworkError.decodingFailed
        } catch {
            let wrapped = NetworkError.unknown(error.localizedDescription)
            await logGETFailure(wrapped)
            throw wrapped
        }
    }

    // MARK: - POST

    func postRating(movieId: Int, title: String, rating: Double) async throws {
        let endpoints = [
            "https://postman-echo.com/post",
            "https://httpbingo.org/post",
            "https://jsonplaceholder.typicode.com/posts",
            "https://reqres.in/api/posts"
        ]

        let body: [String: Any] = [
            "movie_id": movieId,
            "title": title,
            "rating": rating,
            "app": "MovieRatings"
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        var lastError: NetworkError = .unknown("Все POST-серверы недоступны")

        for endpoint in endpoints {
            guard let url = URL(string: endpoint) else { continue }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyData

            do {
                let (data, response) = try await session.data(for: request)
                try validate(response)
                if data.isEmpty { throw NetworkError.noData }

                await logPOSTSuccess()
                return
            } catch let error as NetworkError {
                lastError = error
                if !error.isRetryable { break }
                continue
            } catch {
                lastError = .unknown(error.localizedDescription)
                continue
            }
        }

        await logPOSTFailure(lastError)
        throw lastError
    }

    // MARK: - Validation

    private func validate(_ response: URLResponse?) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.serverError(http.statusCode)
        }
    }

    // MARK: - Logging (main actor hop)

    private func logGETSuccess(count: Int) async {
        await Task { @MainActor in
            NetworkLogger.shared.logGET(success: true, count: count)
        }.value
    }

    private func logGETFailure(_ error: NetworkError) async {
        await Task { @MainActor in
            NetworkLogger.shared.logGET(success: false, error: error.errorDescription)
        }.value
    }

    private func logPOSTSuccess() async {
        await Task { @MainActor in
            NetworkLogger.shared.logPOST(success: true)
        }.value
    }

    private func logPOSTFailure(_ error: NetworkError) async {
        await Task { @MainActor in
            NetworkLogger.shared.logPOST(success: false, error: error.errorDescription)
        }.value
    }
}

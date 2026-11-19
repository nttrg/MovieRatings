import Foundation

enum NetworkError: LocalizedError, Equatable, Sendable {
    case invalidURL
    case invalidResponse
    case noData
    case decodingFailed
    case serverError(Int)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:            return "Некорректный URL"
        case .invalidResponse:       return "Некорректный ответ сервера"
        case .noData:                return "Сервер не вернул данные"
        case .decodingFailed:        return "Ошибка парсинга JSON"
        case .serverError(let code): return "Ошибка сервера: \(code)"
        case .unknown(let message):  return message
        }
    }

    var isRetryable: Bool {
        switch self {
        case .serverError(let code): return code >= 500
        case .noData, .unknown:      return true
        case .invalidURL, .invalidResponse, .decodingFailed:
            return false
        }
    }
}

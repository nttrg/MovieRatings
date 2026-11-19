import Foundation

@MainActor
final class NetworkLogger {
    static let shared = NetworkLogger()

    var lastGETStatus: String = "—"
    var lastPOSTStatus: String = "—"
    var lastError: String = "—"
    var lastParsedCount: Int = 0
    var logs: [String] = []

    private let maxLogs = 30

    private init() {}

    func logGET(success: Bool, count: Int = 0, error: String? = nil) {
        lastGETStatus = success ? "✅ OK (\(count) фильмов)" : "❌ Ошибка"
        lastParsedCount = count
        if let error { lastError = error }
        append("GET: \(lastGETStatus)")
    }

    func logPOST(success: Bool, error: String? = nil) {
        lastPOSTStatus = success ? "✅ OK" : "❌ Ошибка"
        if let error { lastError = error }
        append("POST: \(lastPOSTStatus)")
    }

    private func append(_ text: String) {
        let time = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logs.insert("[\(time)] \(text)", at: 0)
        if logs.count > maxLogs { logs = Array(logs.prefix(maxLogs)) }
    }

    func clear() {
        lastGETStatus = "—"
        lastPOSTStatus = "—"
        lastError = "—"
        lastParsedCount = 0
        logs.removeAll()
    }
}

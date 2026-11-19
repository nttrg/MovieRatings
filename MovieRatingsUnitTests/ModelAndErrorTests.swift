import XCTest
@testable import MovieRatings

final class ModelAndErrorTests: XCTestCase {
    
    // Тест 1: Парсинг JSON и дефолтные значения
    func testJSONParsingAndDefaults() throws {
        let json = """
        {
          "id": 550,
          "title": "Бойцовский клуб",
          "overview": null,
          "poster_path": null,
          "vote_average": 8.4,
          "release_date": null
        }
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(MovieDTO.self, from: json)
        let movie = dto.toMovie()
        
        XCTAssertEqual(dto.id, 550)
        XCTAssertEqual(movie.title, "Бойцовский клуб")
        XCTAssertEqual(movie.overview, "Описание отсутствует")
        XCTAssertEqual(movie.releaseDate, "—")
        XCTAssertNil(movie.posterPath)
    }
    
    // Тест 2: Тексты ошибок
    func testNetworkErrorDescriptions() {
        XCTAssertEqual(NetworkError.invalidURL.errorDescription, "Некорректный URL")
        XCTAssertEqual(NetworkError.serverError(500).errorDescription, "Ошибка сервера: 500")
        XCTAssertEqual(NetworkError.noData, NetworkError.noData)
    }
}

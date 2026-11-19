import XCTest
import SwiftData
@testable import MovieRatings

private struct MockAPI: MovieAPIServiceProtocol {
    var fetchResult: Result<[MovieDTO], Error> = .success([])
    var postResult: Result<Void, Error> = .success(())
    
    func fetchPopularMovies(page: Int) async throws -> [MovieDTO] {
        return try fetchResult.get()
    }
    
    func searchMovies(query: String) async throws -> [MovieDTO] {
        return []
    }
    
    func postRating(movieId: Int, title: String, rating: Double) async throws {
        return try postResult.get()
    }
}

@MainActor
final class ViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Movie.self, configurations: config)
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil; context = nil
    }

    // Тест 1: ListViewModel загружает и сохраняет в БД
    func testMovieListLoadsAndSaves() async throws {
        let dto = MovieDTO(id: 1, title: "Test", overview: "Test", posterPath: nil, voteAverage: 8.0, releaseDate: "2024")
        let mock = MockAPI(fetchResult: .success([dto]))
        
        let viewModel = MovieListViewModel(modelContext: context, api: mock)
        await viewModel.loadMoviesFromAPI()
        
        let movies = try context.fetch(FetchDescriptor<Movie>())
        XCTAssertEqual(movies.count, 1)
        XCTAssertNil(viewModel.errorMessage)
    }

    // Тест 2: DetailViewModel сохраняет оценку
    func testMovieDetailSavesRating() async throws {
        let movie = Movie(id: 1, title: "Dune", overview: "", posterPath: nil, voteAverage: 8, releaseDate: "2021")
        context.insert(movie)
        try context.save()
        
        let mock = MockAPI()
        let viewModel = MovieDetailViewModel(movieId: 1, modelContext: context, api: mock)
        
        let expectation = XCTestExpectation(description: "Ожидание сохранения оценки")
        
        viewModel.userRating = 9.0
        viewModel.saveRating(for: movie)
        
        let start = Date()
        while viewModel.postSuccess == false && Date().timeIntervalSince(start) < 2.0 {
            try await Task.sleep(nanoseconds: 50_000_000) // проверяем каждые 0.05 сек
        }
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(movie.userRating, 9.0)
        XCTAssertTrue(viewModel.postSuccess)
    }
}

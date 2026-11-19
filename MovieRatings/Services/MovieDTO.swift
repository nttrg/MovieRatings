import Foundation

struct MoviesResponse: Decodable, Sendable {
    let results: [MovieDTO]
}

struct MovieDTO: Decodable, Sendable, Equatable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }

    func toMovie() -> Movie {
        Movie(
            id: id,
            title: title,
            overview: overview ?? "Описание отсутствует",
            posterPath: posterPath,
            voteAverage: voteAverage,
            releaseDate: releaseDate ?? "—",
            runtime: nil,
            userRating: nil
        )
    }
}

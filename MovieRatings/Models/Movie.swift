import Foundation
import SwiftData

@Model
final class Movie {
    var id: Int
    var title: String
    var overview: String
    var posterPath: String?
    var voteAverage: Double
    var releaseDate: String
    var runtime: Int?
    var userRating: Double?
    var isFavorite: Bool = false
    
    init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String? = nil,
        voteAverage: Double,
        releaseDate: String,
        runtime: Int? = nil,
        userRating: Double? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.userRating = userRating
        self.isFavorite = isFavorite
    }
}

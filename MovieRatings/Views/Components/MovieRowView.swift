import SwiftUI

struct MovieRowView: View {
    let movie: Movie

    var body: some View {
        HStack(spacing: 16) {
            PosterThumbnail(path: movie.posterPath)
                .frame(width: 80, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if movie.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                            .font(.subheadline)
                            .padding(.top, 2)
                    }
                }

                Text(String(movie.releaseDate.prefix(4)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Theme.star)
                        .font(.caption)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                if let userRating = movie.userRating {
                    Text("Ваша оценка: \(String(format: "%.1f", userRating))")
                        .font(.caption)
                        .foregroundStyle(Theme.accent)
                        .fontWeight(.medium)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }
}

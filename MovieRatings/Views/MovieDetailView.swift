import SwiftUI
import SwiftData

struct MovieDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let movieId: Int

    @Query private var movies: [Movie]
    @State private var viewModel: MovieDetailViewModel?

    private var movie: Movie? { movies.first }

    init(movieId: Int) {
        self.movieId = movieId
        let id = movieId
        _movies = Query(filter: #Predicate<Movie> { $0.id == id })
    }

    var body: some View {
        Group {
            if let movie {
                content(for: movie)
            } else {
                ContentUnavailableView(
                    "Фильм не найден",
                    systemImage: "film",
                    description: Text("Данные отсутствуют в локальной базе")
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                viewModel = MovieDetailViewModel(
                    movieId: movieId,
                    modelContext: modelContext
                )
            }
        }
    }

    @ViewBuilder
    private func content(for movie: Movie) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                posterSection(for: movie)
                infoSection(for: movie)
            }
            .padding(.bottom, 30)
        }
    }

    @ViewBuilder
    private func posterSection(for movie: Movie) -> some View {
        PosterThumbnail(path: movie.posterPath)
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(16)
            .padding(.horizontal)
    }

    @ViewBuilder
    private func infoSection(for movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(movie.title)
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                Button {
                    viewModel?.toggleFavorite(movie)
                } label: {
                    Image(systemName: movie.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(.pink)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 16) {
                Label(String(movie.releaseDate.prefix(4)), systemImage: "calendar")

                if let runtime = movie.runtime {
                    Label("\(runtime) мин", systemImage: "clock")
                }

                Label(String(format: "%.1f", movie.voteAverage), systemImage: "star.fill")
                    .foregroundStyle(Theme.star)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Divider()

            Text("Описание")
                .font(.headline)

            Text(movie.overview)
                .font(.body)
                .foregroundStyle(.secondary)

            Divider()

            ratingSection(for: movie)
        }
        .padding(.horizontal)
    }

    // ИСПРАВЛЕНИЕ: Функция стала короче за счет выноса вложенных View
    @ViewBuilder
    private func ratingSection(for movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ваша оценка")
                .font(.headline)

            if viewModel?.isSending == true {
                SendingRatingView()
            } else if let saved = movie.userRating {
                SavedRatingView(
                    savedRating: saved,
                    isSuccess: viewModel?.postSuccess == true,
                    error: viewModel?.postError,
                    onRemove: { viewModel?.removeRating(for: movie) }
                )
            } else {
                EditRatingView(
                    rating: Binding(
                        get: { viewModel?.userRating ?? 0 },
                        set: { viewModel?.userRating = $0 }
                    ),
                    error: viewModel?.postError,
                    onSave: { viewModel?.saveRating(for: movie) }
                )
            }
        }
    }
}

// MARK: - Дополнительные View для разгрузки основного кода

private struct SendingRatingView: View {
    var body: some View {
        HStack {
            ProgressView()
            Text("Отправка оценки...")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

private struct SavedRatingView: View {
    let savedRating: Double
    let isSuccess: Bool
    let error: String?
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Оценка \(String(format: "%.1f", savedRating)) сохранена")
                    .fontWeight(.medium)
            }

            if isSuccess, error == nil {
                Text("Отправлено на сервер (POST)")
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Button(role: .destructive, action: onRemove) {
                Text("Удалить оценку")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct EditRatingView: View {
    @Binding var rating: Double
    let error: String?
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(format: "%.1f", rating))
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(width: 50)

                Slider(value: $rating, in: 0...10, step: 0.5)
                    .tint(Theme.star)
            }

            Button(action: onSave) {
                Text("Сохранить оценку")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
            .disabled(rating == 0)

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movieId: 1)
    }
    .modelContainer(for: Movie.self, inMemory: true)
}

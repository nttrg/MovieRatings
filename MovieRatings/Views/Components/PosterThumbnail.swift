import SwiftUI

struct PosterThumbnail: View {
    let path: String?

    var body: some View {
        Group {
            if let path,
               let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholder
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.2)
                            ProgressView()
                        }
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            Theme.posterGradient
            Image(systemName: "film")
                .font(.system(size: 28))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

import SwiftUI
import SwiftData

@main
struct MovieRatingsApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: Movie.self)
    }
}

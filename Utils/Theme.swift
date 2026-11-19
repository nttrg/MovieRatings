import SwiftUI

enum Theme {
    static let accent = Color.blue
    static let star = Color.yellow

    static let posterGradient = LinearGradient(
        colors: [Color.indigo, Color.pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cornerRadius: CGFloat = 12
}

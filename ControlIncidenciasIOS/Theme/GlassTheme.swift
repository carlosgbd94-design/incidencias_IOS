import SwiftUI

struct GlassColors {
    static let samsungBlue = Color(red: 10/255, green: 89/255, blue: 234/255)
    static let successGreen = Color(red: 16/255, green: 185/255, blue: 129/255)
    static let warningOrange = Color(red: 245/255, green: 158/255, blue: 11/255)
    static let alertRed = Color(red: 239/255, green: 68/255, blue: 68/255)
}

struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    if colorScheme == .dark {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(white: 1.0, opacity: 0.05))
                    } else {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(0.85))
                    }
                }
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.25 : 0.6),
                                Color.white.opacity(colorScheme == .dark ? 0.05 : 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
    }
}

extension View {
    func glassCard() -> some View {
        self.modifier(GlassCardModifier())
    }
}

import SwiftUI

// https://m2.material.io/design/color/dark-theme.html#ui-application
extension Color {

    enum ColorEmphasis: CGFloat {
        case high = 0.87
        case medium = 0.6
        case disabled = 0.38
    }

    static let background = Color(hex: 0x121212)

    static func overlay(opacity: CGFloat = 0.05) -> Color {
        white.opacity(opacity)
    }

    static func text(emphasis: ColorEmphasis = .high) -> Color {
        white.opacity(emphasis.rawValue)
    }

}

extension Color {

    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

}

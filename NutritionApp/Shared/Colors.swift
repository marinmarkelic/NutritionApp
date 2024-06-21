import SwiftUI

// https://m2.material.io/design/color/dark-theme.html#ui-application

// MARK: Elements
extension Color {

    static let background = Color(hex: 0x121212)
    static let action = Color(hex: 0xBB86FC)
    static let chatBubble = Color(hex: 0xFFFBE6)
    static let icon = Color.white.opacity(0.6)
    static let iconDisabled = Color.white.opacity(0.38)

    static func overlay(opacity: CGFloat = 0.05) -> Color {
        white.opacity(opacity)
    }

}

// MARK: Text
extension Color {

    enum ColorEmphasis: CGFloat {
        case high = 0.87
        case medium = 0.6
        case disabled = 0.38
    }

    static let chatTextQuestion = Color.black.opacity(0.8)
    static let chatTextResponse = Color.white.opacity(0.8)

    static func text(emphasis: ColorEmphasis = .high) -> Color {
        white.opacity(emphasis.rawValue)
    }

}

// MARK: - Nutrient colors
extension Color {

    static let protein = Color(hex: 0xFF613F)
    static let carbs = Color(hex: 0xBA8C82)
    static let fat = Color(hex: 0xFFFFC1)
    static let fatSaturated = Color(hex: 0xFFD700)
    static let sodium = Color(hex: 0xFFA500)
    static let potassium = Color(hex: 0xE0E8F0)
    static let cholesterol = Color(hex: 0xC0392B)
    static let fiber = Color(hex: 0x32CD32)
    static let sugar = Color(hex: 0xFF69B4)

}

extension Color {

    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

}

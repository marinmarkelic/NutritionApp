import SwiftUI

extension Text {

    init(_ string: Strings) {
        self.init(string.rawValue)
    }

    func color(emphasis: Color.ColorEmphasis) -> Text {
        foregroundStyle(Color.text(emphasis: emphasis))
    }

}

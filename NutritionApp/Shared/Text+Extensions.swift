import SwiftUI

extension Text {

    func color(emphasis: Color.ColorEmphasis) -> Text {
        foregroundStyle(Color.text(emphasis: emphasis))
    }

}

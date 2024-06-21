import SwiftUI

enum Icon: String {

    case trash
    case magniflyingGlass = "magnifyingglass"
    case send = "arrow.turn.right.up"
    case history = "gobackward"
    case visible = "eye.fill"
    case hidden = "eye.slash.fill"

}

extension Image {

    init(with icon: Icon) {
        self.init(systemName: icon.rawValue)
    }

}

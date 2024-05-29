import SwiftUI

struct SizePreferenceKey: PreferenceKey {

    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}

}

struct SafeAreaPreferenceKey: PreferenceKey {

    static var defaultValue: EdgeInsets = .init()
    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {}

}

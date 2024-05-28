import SwiftUI

enum BundleImage: String {

    case send
    case search

}

extension UIImage {

    convenience init(from bundle: BundleImage) {
        self.init(named: bundle.rawValue)!
    }

}

extension Image {

    init(from bundle: BundleImage) {
        self.init(uiImage: UIImage(from: bundle))
    }

}

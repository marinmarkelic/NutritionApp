import Foundation

extension CGFloat {

    func rounded(toPlaces places: Int = 2) -> CGFloat {
        let multiplier = pow(10.0, CGFloat(places))

        return (self * multiplier).rounded() / multiplier
    }

}


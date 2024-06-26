extension Float {

    func toInt() -> Int {
        guard self.isNormal else { return .zero }

        return Int(self)
    }

    func formatWithDecimalPoint() -> String {
        "%d.1"
    }

}

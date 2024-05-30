extension Int {

    init?(_ value: Double?) {
        guard let value else { return nil }

        self.init(value)
    }

}

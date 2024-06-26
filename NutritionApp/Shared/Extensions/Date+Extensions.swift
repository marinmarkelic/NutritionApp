import Foundation

extension Date {

    var onlyDate: Date? {
        var calendar = Calendar.current
        calendar.timeZone = .gmt

        return calendar.date(from: calendar.dateComponents([.year, .month, .day], from: self))
    }

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }

    static func dateWithAdded(days: Int) -> Date {
        guard let date = Calendar.current.date(byAdding: .day, value: days, to: Date()) else { return .now }

        return date
    }

}

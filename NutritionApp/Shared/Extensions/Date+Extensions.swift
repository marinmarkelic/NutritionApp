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
        let calendar = Calendar.current

        guard
            let date = calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: .now))
        else { return .now }

        return date
    }

}

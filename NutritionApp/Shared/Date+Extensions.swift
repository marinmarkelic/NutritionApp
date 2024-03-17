import Foundation

extension Date {

    var onlyDate: Date? {
        var calendar = Calendar.current
        calendar.timeZone = .gmt

        return calendar.date(from: calendar.dateComponents([.year, .month, .day], from: self))
    }

}

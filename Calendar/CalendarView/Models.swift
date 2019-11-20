//
//  File.swift
//  
//
//  Created by roy on 2019/11/18.
//

import Foundation

let calendar = Calendar.current

// MARK: - Day
extension Date: CalendarDayType {
    public var date: Date { self }
}

// MARK: - Week
public enum Weekday: Int, Equatable, CaseIterable {
    case sun = 1
    case mon
    case tue
    case wed
    case thu
    case fri
    case sat
    
    public static var weekdays: [Weekday] { allCases }
    public static var count: Int { weekdays.count }
    public var symbol: String { calendar.weekdaySymbols[rawValue - 1] }
    public var shortSymbol: String { calendar.shortWeekdaySymbols[rawValue - 1] }
}

// MARK: - Month
public struct Month {
    let startDay: Date
    let endDay: Date
    /// day's count in current month
    let daysCount: Int
    
    var month: Int { calendar.component(.month, from: startDay) }
    var year: Int { calendar.component(.year, from: startDay) }
    /// total days will show in month section
    var showCount: Int { startDay.weekdayValue - 1 + daysCount + Weekday.count - endDay.weekdayValue }
    var next: Month {
        .init(date: calendar.date(byAdding: .month, value: 1, to: startDay)!)
    }
    
    var pre: Month {
        .init(date: calendar.date(byAdding: .month, value: -1, to: startDay)!)
    }

    /// initialize
    /// - Parameter date: one date in this month
    init(date: Date = .init()) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: date)
        startDay = calendar.date(from: components)!
        components.month = components.month! + 1
        components.day = 0
        endDay = calendar.date(from: components)!
        daysCount = calendar.range(of: .day, in: .month, for: date)!.count
    }
    
    func date(at index: Int) -> Date {
        let value = index - (startDay.weekdayValue - 1)
        return calendar.date(byAdding: .day, value: value, to: startDay)!
    }
    
    func dayPosition(at index: Int) -> DayPosition {
        switch index - (startDay.weekdayValue - 1) {
        case let value where value < 0:
            return .pre
        case 0..<daysCount:
            return .inner
        default:
            return .next
        }
    }
}

extension Month {
    public enum DayPosition: Int, Equatable, CaseIterable {
        /// 在该月显示的上个月的日期
        case pre
        /// 在该月显示的该月日期
        case inner
        /// 在该月显示的下个月日期
        case next
    }
}

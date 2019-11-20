//
//  File.swift
//  
//
//  Created by roy on 2019/11/18.
//

import Foundation
import UIKit

public struct CalendarViewModel {
    private(set) var indexOfDefaultMonth: Int
    private(set) var indexOfShowingMonth: Int
    
    private var months: [Month]
        
    init(defaultDate date: Date, initialMonthCount count: Int) {
        let indexOfDefaultMonth = count / 2
        var month = Month(date: date)
        
        var preMonth = month.pre
        var months = [Month]()
        
        (0..<indexOfDefaultMonth).forEach { _ in
            months = [preMonth] + months + [month]
            preMonth = preMonth.pre
            month = month.next
        }
        
        if months.count < count {
            months.append(month.next)
        }
        
        self.months = months
        self.indexOfDefaultMonth = indexOfDefaultMonth
        self.indexOfShowingMonth = indexOfDefaultMonth
    }
}

// MARK: - Data source
extension CalendarViewModel {
    var monthCount: Int { months.count }
    var indexOfPreMonth: Int { indexOfShowingMonth - 1 }
    var indexOfNextMonth: Int { indexOfShowingMonth + 1 }
    var showingMonth: Month { month(at: indexOfShowingMonth) }
    
    func month(at section: Int) -> Month {
        return months[section]
    }
    
    func numberOfDays(at section: Int) -> Int {
        return month(at: section).showCount
    }
    
    func day(at indexPath: IndexPath) -> CalendarDayType {
        return month(at: indexPath.section).date(at: indexPath.row)
    }
    
    func dayPosition(at indexPath: IndexPath) -> Month.DayPosition {
        return month(at: indexPath.section).dayPosition(at: indexPath.row)
    }
}

extension CalendarViewModel {
    fileprivate enum Increment {
        case pre(count: Int)
        case next(count: Int)
    }
    
    private var incrementCount: Int { 12 }

    mutating func shouldSilenceScrollNewDestination(didShowingMonthAt index: Int) -> Int? {
        indexOfShowingMonth = index
        
        switch index {
        case let index where index < incrementCount:
            increase(.pre(count: incrementCount))
            return incrementCount + index
        case let index where index >= monthCount - incrementCount:
            increase(.next(count: incrementCount))
            return index
        default:
            return nil
        }
    }
    
    mutating private func increase(_ increment: Increment) {
        switch increment {
        case .pre(let count):
            (0..<count).forEach { _ in
                guard let first = months.first else { return }
                months.insert(first.pre, at: 0)
            }
            indexOfShowingMonth += count
            indexOfDefaultMonth += count
        case .next(let count):
            (0..<count).forEach { _ in
                guard let last = months.last else { return }
                months.append(last.next)
            }
        }
    }
}

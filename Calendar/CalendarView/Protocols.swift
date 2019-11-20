//
//  File.swift
//  
//
//  Created by roy on 2019/11/18.
//

import UIKit

public protocol CalendarCellType: UICollectionViewCell {
    func toggle()
    func config(_ info: CalendarDayType, dayPosition position: Month.DayPosition, collectionView collection: UICollectionView, scrollDirection direction: UICollectionView.ScrollDirection)
}

// MARK: - CalendarDayType
public protocol CalendarDayType {
    var date: Date { get }
}

extension CalendarDayType {
    public var weekdayValue: Int { calendar.component(.weekday, from: date) }
    public var weekday: Weekday { Weekday(rawValue: weekdayValue)! }
    public var day: Int { calendar.component(.day, from: date) }
    public var isToday: Bool { calendar.isDate(date, inSameDayAs: Date()) }
    public var dateYMDString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - day configuration
public protocol CalendarDayConfigrationType {
    // required
    var cellType: CalendarCellType.Type { get }
    var itemSize: CGSize { get }
    
    // optional
    var defaultShowingDate: Date { get }
    var initialMonthCount: Int { get }
    var lineSpacing: CGFloat { get }
    var interitemSpacing: CGFloat { get }
    var scrollDirection: UICollectionView.ScrollDirection { get }
}

extension CalendarDayConfigrationType {
    var defaultShowingDate: Date { .init() }
    var initialMonthCount: Int { 12 }
    var cellReuseIdentifier: String { "\(cellType.self)" }
    var lineSpacing: CGFloat { 2 }
    var interitemSpacing: CGFloat { 2 }
    var scrollDirection: UICollectionView.ScrollDirection { .vertical }
    var columns: Int { 7 }
    var lines: Int { 5 }
    var calendarSize: CGSize {
        .init(width: CGFloat(columns) * (itemSize.width + interitemSpacing) - interitemSpacing,
              height: CGFloat(lines) * (itemSize.height + lineSpacing) - lineSpacing)
    }
}

// MARK: - weekday configuration
public protocol CalendarWeekdayConfigrationType {
    var height: CGFloat { get }
    var textFont: UIFont { get }
    var backgroundColor: UIColor { get }
    
    func textColor(for weekday: Weekday) -> UIColor
    func text(for weekday: Weekday) -> String
}

// MARK: - month configuration
public protocol CalendarMonthViewType: UIView {
    var navigator: CalendarViewNavigatable? { get set }
    
    func config(_ month: Month)
}

// MARK: - month configuration
public protocol CalendarMonthConfigrationType {
    var height: CGFloat { get }
    var view: CalendarMonthViewType { get }
}

// MARK: - CalendarView configuration
public protocol CalendarViewConfigurationType {
    var day: CalendarDayConfigrationType { get }
    var weekday: CalendarWeekdayConfigrationType { get }
    var month: CalendarMonthConfigrationType { get }
}

public protocol CalendarViewNavigatable: class {
    func gotoNextMonth(_ animated: Bool)
    func gotoPreMonth(_ animated: Bool)
    func gotoDefaultDay(_ animated: Bool)
}

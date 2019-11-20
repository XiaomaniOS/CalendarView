//
//  CalendarViewController.swift
//  Calendar
//
//  Created by roy on 2019/11/18.
//  Copyright © 2019 xiaoman. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {
    init(_ scrollDirection: UICollectionView.ScrollDirection = .horizontal) {
        calendarView = .init(config: Configration(scrollDirection))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let calendarView: CalendarView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        contructViewHierarchyAndConstraint()
    }

    private func contructViewHierarchyAndConstraint() {
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100)
            ])
        } else {
            NSLayoutConstraint.activate([
                calendarView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            ])
        }
        
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.heightAnchor.constraint(equalToConstant: 460)
        ])
    }
}

extension CalendarViewController {
    struct Configration: CalendarViewConfigurationType {
        var day: CalendarDayConfigrationType
        var weekday: CalendarWeekdayConfigrationType = Week()
        var month: CalendarMonthConfigrationType = Month()
        
        init(_ scrollDirection: UICollectionView.ScrollDirection = .horizontal) {
            self.day = Day(scrollDirection: scrollDirection)
        }
        
        struct Day: CalendarDayConfigrationType {
            var itemSize: CGSize { .init(width: 55, height: 100) }
            var cellType: CalendarCellType.Type { CalendarItemCell.self }
            var scrollDirection: UICollectionView.ScrollDirection
            var lineSpacing: CGFloat { 0 }
            var interitemSpacing: CGFloat { 0 }
        }
        
        struct Week: CalendarWeekdayConfigrationType {
            var height: CGFloat { 80 }
            var textFont: UIFont { .systemFont(ofSize: 15) }
            var backgroundColor: UIColor { .white }
            
            func textColor(for weekday: Weekday) -> UIColor {
                switch weekday {
                case .sat, .sun:
                    return .darkGray
                default:
                    return .black
                }
            }
            
            func text(for weekday: Weekday) -> String {
                weekday.shortSymbol
            }
        }
        
        struct Month: CalendarMonthConfigrationType {
            var view: CalendarMonthViewType = MonthView(frame: .zero)
            var height: CGFloat { 50 }
        }
    }
}

extension CalendarViewController {
    class MonthView: UIView, CalendarMonthViewType {
        private let previousButton = UIButton()
        private let nextButton = UIButton()
        private let todayButton = UIButton()
        private let monthLabel = UILabel()
        
        var navigator: CalendarViewNavigatable?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contructViewHierarchyAndConstraint()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            print("MonthView deinit")
        }
        
        private func contructViewHierarchyAndConstraint() {
            addSubview(previousButton)
            previousButton.translatesAutoresizingMaskIntoConstraints = false
            previousButton.setTitle("pre", for: .normal)
            previousButton.setTitleColor(.black, for: .normal)
            
            addSubview(nextButton)
            nextButton.translatesAutoresizingMaskIntoConstraints = false
            nextButton.setTitle("next", for: .normal)
            nextButton.setTitleColor(.black, for: .normal)
            
            addSubview(todayButton)
            todayButton.translatesAutoresizingMaskIntoConstraints = false
            todayButton.setTitle("today", for: .normal)
            todayButton.setTitleColor(.black, for: .normal)
            
            addSubview(monthLabel)
            monthLabel.translatesAutoresizingMaskIntoConstraints = false
            monthLabel.textAlignment = .center
            monthLabel.font = .systemFont(ofSize: 20)
            monthLabel.text = "1234"
            monthLabel.backgroundColor = .white
            monthLabel.textColor = .black
            
            let buttonWidth: CGFloat = 55
            NSLayoutConstraint.activate([
                previousButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 80),
                previousButton.topAnchor.constraint(equalTo: topAnchor),
                previousButton.widthAnchor.constraint(equalToConstant: buttonWidth),
                previousButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -80),
                nextButton.topAnchor.constraint(equalTo: topAnchor),
                nextButton.widthAnchor.constraint(equalToConstant: buttonWidth),
                nextButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                todayButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                todayButton.topAnchor.constraint(equalTo: topAnchor),
                todayButton.widthAnchor.constraint(equalToConstant: buttonWidth),
                todayButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                monthLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                monthLabel.topAnchor.constraint(equalTo: topAnchor),
                monthLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
            
            previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
            nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
            todayButton.addTarget(self, action: #selector(todayButtonTapped), for: .touchUpInside)
        }
        
        @objc
        private func previousButtonTapped() {
            navigator?.gotoPreMonth(true)
        }
        
        @objc
        private func nextButtonTapped() {
            navigator?.gotoNextMonth(true)
        }
        
        @objc
        private func todayButtonTapped() {
            navigator?.gotoDefaultDay(true)
        }
        
        func config(_ month: Month) {
            monthLabel.text = "\(month.year)/\(month.month)"
        }
    }
}

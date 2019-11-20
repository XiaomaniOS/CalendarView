//
//  CalendarView.swift
//
//
//  Created by roy on 2019/11/17.
//

import UIKit

protocol CalendarViewDelegate {
    func calendarView(_ calendarView: CalendarView, didSelectedCell cell: UICollectionViewCell)
}

public class CalendarView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CalendarViewNavigatable {
    
    private let config: CalendarViewConfigurationType
    private var isScrolledToAutoShowingDate = false
    private var viewModel: CalendarViewModel
    private var collectionView: UICollectionView
    
    public init(config: CalendarViewConfigurationType) {
        self.config = config
        
        let layout = CalendarCollectionViewLayout()
        layout.itemSize = config.day.itemSize
        layout.lineSpacing = config.day.lineSpacing
        layout.interitemSpacing = config.day.interitemSpacing
        layout.scrollDirection = config.day.scrollDirection
        collectionView = .init(frame: .zero, collectionViewLayout: layout)
        
        viewModel = .init(
            defaultDate: config.day.defaultShowingDate,
            initialMonthCount: config.day.initialMonthCount
        )
        
        super.init(frame: .zero)
        
        constructViewHierarchyAndConstruct()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func constructViewHierarchyAndConstruct() {
        let monthView = config.month.view
        addSubview(monthView)
        monthView.translatesAutoresizingMaskIntoConstraints = false
        monthView.navigator = self
        
        let headerStack = UIStackView()
        addSubview(headerStack)
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.distribution = .fillEqually
        headerStack.spacing = config.day.interitemSpacing
        headerStack.alignment = .center
        headerStack.backgroundColor = config.weekday.backgroundColor
        
        Weekday.allCases.forEach {
            let label = UILabel()
            label.text = config.weekday.text(for: $0)
            label.textColor = config.weekday.textColor(for: $0)
            label.font = config.weekday.textFont
            label.textAlignment = .center
            
            headerStack.addArrangedSubview(label)
        }
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                monthView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                monthView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                monthView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                headerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                headerStack.topAnchor.constraint(equalTo: topAnchor),
                headerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
        }
        
        NSLayoutConstraint.activate([
            monthView.heightAnchor.constraint(equalToConstant: config.month.height),
            headerStack.topAnchor.constraint(equalTo: monthView.bottomAnchor),
            headerStack.centerXAnchor.constraint(equalTo: monthView.centerXAnchor),
            headerStack.widthAnchor.constraint(equalToConstant: config.day.calendarSize.width),
            headerStack.heightAnchor.constraint(equalToConstant: config.weekday.height),
            collectionView.leadingAnchor.constraint(equalTo: headerStack.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: headerStack.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: config.day.calendarSize.height)
        ])
        
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(config.day.cellType.self, forCellWithReuseIdentifier: config.day.cellReuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        config.month.view.config(viewModel.showingMonth)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard !isScrolledToAutoShowingDate else { return }
        gotoDefaultDay(false)
    }
    
    public func gotoNextMonth(_ animated: Bool = true) {
        scrollToItem(at: .init(row: 0, section: viewModel.indexOfNextMonth), animated: animated)
    }

    public func gotoPreMonth(_ animated: Bool = true) {
        scrollToItem(at: .init(row: 0, section: viewModel.indexOfPreMonth), animated: animated)
    }

    public func gotoDefaultDay(_ animated: Bool = true) {
        scrollToItem(at: .init(row: 0, section: viewModel.indexOfDefaultMonth), animated: animated)
    }
    
    private func changeMonthAndAskShouldSilenceScroll(with section: Int) {
        if let destinationSection = viewModel.shouldSilenceScrollNewDestination(didShowingMonthAt: section) {
            collectionView.reloadData()
            scrollToItem(at: .init(row: 0, section: destinationSection), animated: false)
        }
        
        config.month.view.config(viewModel.showingMonth)
    }
    
    private func scrollToItem(at indexPath: IndexPath, animated: Bool) {
        collectionView.scrollToItem(
            at: indexPath, at: .horizontal == config.day.scrollDirection ? .left : .top,
            animated: animated
        )
    }

    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseCell = collectionView.dequeueReusableCell(withReuseIdentifier: config.day.cellReuseIdentifier, for: indexPath)
        
        if let cell = reuseCell as? CalendarCellType {
            cell.config(
                viewModel.day(at: indexPath),
                dayPosition: viewModel.dayPosition(at: indexPath),
                collectionView: collectionView,
                scrollDirection: config.day.scrollDirection
            )
        }
        
        return reuseCell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.monthCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfDays(at: section)
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CalendarCellType {
            cell.toggle()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    private func caculateCurrentVisableSection(ofContentOffset offset: CGPoint, andScrollBoundSize size: CGSize) -> Int {
        switch config.day.scrollDirection {
        case .horizontal:
            return (offset.x / CGFloat(size.width)).roundedIntValue
        default:
            return (offset.y / CGFloat(size.height)).roundedIntValue
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let section = caculateCurrentVisableSection(ofContentOffset: scrollView.contentOffset, andScrollBoundSize: scrollView.bounds.size)
        changeMonthAndAskShouldSilenceScroll(with: section)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let section = caculateCurrentVisableSection(ofContentOffset: scrollView.contentOffset, andScrollBoundSize: scrollView.bounds.size)
        changeMonthAndAskShouldSilenceScroll(with: section)
    }
}

fileprivate extension CGFloat {
     var roundedIntValue: Int {
        let value = Int(self)
        if self ~= CGFloat(value + 1) {
            return value + 1
        } else {
            return value
        }
    }
    
    static func ~=(lsh: CGFloat, rsh: CGFloat) -> Bool {
        return abs(lsh - rsh) < 0.2
    }
}

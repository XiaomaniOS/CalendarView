//
//  CalendarItemCell.swift
//  Calendar
//
//  Created by roy on 2019/11/20.
//  Copyright © 2019 xiaoman. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class CalendarItemCell: UICollectionViewCell, CalendarCellType {
    
    private let dayLabel = UILabel()
    var detailLabel = UILabel()
    private let tableView = UITableView()
    private var closeButton = UIButton()
    
    /// expand
    private lazy var animator: UIViewPropertyAnimator = {
        .init(duration: 1, dampingRatio: 1, animations: nil)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        constructViewHieraychyAndConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews
    private func constructViewHieraychyAndConstraint() {
        contentView.addSubview(dayLabel)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.textAlignment = .center
        dayLabel.font = .systemFont(ofSize: 18)
        
        contentView.addSubview(detailLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.textAlignment = .center
        detailLabel.font = .systemFont(ofSize: 12)
        detailLabel.tag = 100
        
        contentView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.alpha = 0
        
        contentView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(collapse), for: .touchUpInside)
        closeButton.backgroundColor = .black
        
        closeButtonWidthConstraint = closeButton.widthAnchor.constraint(equalToConstant: 0)
        closeButtonWidthConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.heightAnchor.constraint(equalToConstant: 30),
            closeButton.centerYAnchor.constraint(equalTo: dayLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            detailLabel.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor),
            detailLabel.centerYAnchor.constraint(equalTo: dayLabel.centerYAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor),
            detailLabel.heightAnchor.constraint(equalToConstant: 30),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 5),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
        
        contentView.layer.cornerRadius = 0
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOffset = .init(width: 2, height: 2)
        contentView.layer.shadowColor = UIColor.white.cgColor
    }
    
    func config(
        _ info: CalendarDayType,
        dayPosition position: Month.DayPosition,
        collectionView collection: UICollectionView,
        scrollDirection direction: UICollectionView.ScrollDirection
    ) {
        dayLabel.text = "\(info.day)"
        contentView.backgroundColor = .inner == position ? .purple : .yellow
        dayLabel.textColor = .inner == position ? .white : .black
        
        if info.isToday {
            dayLabel.textColor = .red
        }
        
        collectionView = collection
        scrollDirection = direction
    }
    
    // MARK: - Animated
    enum State {
        case expanded
        case collapsed
        
        var opposite: State {
            switch self {
            case .expanded: return .collapsed
            case .collapsed: return .expanded
            }
        }
    }
    
    private let cornerRadius: CGFloat = 5
    private var state: State = .collapsed
    private var initialFrame = CGRect.zero
    private weak var collectionView: UICollectionView?
    private var closeButtonWidthConstraint = NSLayoutConstraint()
    private var scrollDirection = UICollectionView.ScrollDirection.horizontal
    
    func toggle() {
        animateTransitionIfNeeded(to: state.opposite, duration: 1)
    }
    
    @objc
    private func collapse() {
        animateTransitionIfNeeded(to: .collapsed, duration: 1)
    }
    
    /// Animates the transition, if the animation is not already running.
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        // ensure that the animators array is empty (which implies new animations need to be created)
        guard let collectionView = self.collectionView else { return }
        
        collectionView.isScrollEnabled = false
        collectionView.allowsSelection = false
        
        // an animator for the transition
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .expanded:
                self.initialFrame = self.frame
                self.closeButtonWidthConstraint.constant = 50
                self.contentView.layer.cornerRadius = self.cornerRadius
                collectionView.bringSubviewToFront(self)
                
                let size = collectionView.frame.size
                let expandedFrame: CGRect
                switch self.scrollDirection {
                case .horizontal:
                    expandedFrame = .init(origin: .init(x: collectionView.contentOffset.x, y: 0), size: size)
                default:
                    expandedFrame = .init(origin: .init(x: 0, y: collectionView.contentOffset.y), size: size)
                }
                
                self.frame = expandedFrame
                self.closeButton.alpha = 1
//                self.tableView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6).concatenating(CGAffineTransform(translationX: 0, y: 15))
                self.tableView.alpha = 1
                self.contentView.layer.shadowColor = UIColor.black.cgColor
            case .collapsed:
                self.closeButtonWidthConstraint.constant = 0
                self.contentView.layer.cornerRadius = 0
                collectionView.bringSubviewToFront(self)
                self.frame = self.initialFrame
                self.closeButton.alpha = 0
//                self.tableView.transform = .identity
                self.tableView.alpha = 0
                self.contentView.layer.shadowColor = UIColor.white.cgColor
            }
            
            self.layoutIfNeeded()
        })
        
        // the transition completion block
        transitionAnimator.addCompletion { position in
            
            // update the state
            switch position {
            case .start:
                self.state = state.opposite
            case .end:
                self.state = state
            case .current:
                ()
            @unknown default:
                ()
            }
            
            // manually reset the constraint positions
            switch self.state {
            case .expanded:
                collectionView.isScrollEnabled = false
                collectionView.allowsSelection = false
                self.closeButton.alpha = 1
            case .collapsed:
                collectionView.isScrollEnabled = true
                collectionView.allowsSelection = true
                self.closeButton.alpha = 0
            }
        }
        
        transitionAnimator.startAnimation()
    }
}

extension CalendarItemCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = "indexPath: \(indexPath.row)"
        return cell
    }
}

extension CalendarItemCell: UITableViewDelegate {
    
}

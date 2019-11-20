//
//  CalendarCollectionViewLayout.swift
//  Calendar
//
//  Created by roy on 2019/11/20.
//  Copyright © 2019 xiaoman. All rights reserved.
//

import UIKit

public final class CalendarCollectionViewLayout: UICollectionViewLayout {
    public var itemSize = CGSize(width: 40, height: 40)
    public var lineSpacing: CGFloat = 2
    public var interitemSpacing: CGFloat = 2
    public var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    
    private let columns = 7
    private let lines = 5
    private var contentBounds = CGRect.zero
    private var cachedAttributes = [[UICollectionViewLayoutAttributes]]()
    
    private func clearCaches() {
        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: collectionView?.bounds.size ?? .zero)
    }
    
    override public func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        // Reset cached information.
        clearCaches()

        (0..<collectionView.numberOfSections).forEach { section in
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            guard numberOfItems > 0 else { return }
            
            (0..<numberOfItems).forEach { row in
                prepare(at: .init(row: row, section: section), sectionNumberOfItems: numberOfItems)
            }
        }
    }
    
    private func prepare(at indexPath: IndexPath, sectionNumberOfItems count: Int) {
        var lastFrame: CGRect = .zero
        let sectionWidth = CGFloat(columns) * (itemSize.width + interitemSpacing) - interitemSpacing
        let sectionHeight = CGFloat(lines) * (itemSize.height + lineSpacing) - lineSpacing
        let extraLineItemHeight = (sectionHeight - CGFloat(lines) * lineSpacing) / CGFloat(lines + 1)
        
        switch (count, scrollDirection) {
        case (columns * lines, .horizontal):
            lastFrame = CGRect(
                x: CGFloat(indexPath.section) * sectionWidth + CGFloat(indexPath.row % columns) * (itemSize.width + interitemSpacing),
                y: CGFloat(indexPath.row / columns) * (itemSize.height + lineSpacing),
                width: itemSize.width,
                height: itemSize.height
            )
        case (columns * lines, .vertical):
            lastFrame = CGRect(
                x: CGFloat(indexPath.row % columns) * (itemSize.width + interitemSpacing),
                y: CGFloat(indexPath.section) * sectionHeight + CGFloat(indexPath.row / columns) * (itemSize.height + lineSpacing),
                width: itemSize.width,
                height: itemSize.height
            )
        case (columns * (lines + 1), .horizontal):
            lastFrame = CGRect(
                x: CGFloat(indexPath.section) * sectionWidth + CGFloat(indexPath.row % columns) * (itemSize.width + interitemSpacing),
                y: CGFloat(indexPath.row / columns) * (extraLineItemHeight + lineSpacing),
                width: itemSize.width,
                height: extraLineItemHeight
            )
        case (columns * (lines + 1), .vertical):
            lastFrame = CGRect(
                x: CGFloat(indexPath.row % columns) * (itemSize.width + interitemSpacing),
                y: CGFloat(indexPath.section) * sectionHeight + CGFloat(indexPath.row / columns) * (extraLineItemHeight + lineSpacing),
                width: itemSize.width,
                height: extraLineItemHeight
            )
        default:
            break
        }

        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = lastFrame
        contentBounds = contentBounds.union(lastFrame)
        insertAttributesCache(with: attributes, at: indexPath)
    }
    
    private func insertAttributesCache(with attributes: UICollectionViewLayoutAttributes, at indexPath: IndexPath) {
        if cachedAttributes.count <= indexPath.section {
            (cachedAttributes.count...indexPath.section).forEach { _ in cachedAttributes.append([]) }
        }
        
        if cachedAttributes[indexPath.section].count > indexPath.row {
            cachedAttributes[indexPath.section].insert(attributes, at: indexPath.row)
        } else {
            cachedAttributes[indexPath.section].append(attributes)
        }
    }
    

    /// - Tag: CollectionViewContentSize
    override public var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.flatMap { $0 }.filter { $0.frame.intersects(rect)}
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            indexPath.section < cachedAttributes.count,
            indexPath.row < cachedAttributes[indexPath.section].count
        else {
            return nil
        }
        
        return cachedAttributes[indexPath.section][indexPath.row]
    }
}

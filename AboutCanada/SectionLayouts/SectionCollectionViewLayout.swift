//  Copyright © 2019 Cognizant. All rights reserved.

import UIKit
import AsyncDisplayKit

protocol SectionCollectionViewLayoutDelegate: ASCollectionDelegate {
    var collectionViewSize: CGSize { get }
    func collectionViewLayout(_ layout: SectionCollectionViewLayout, numberOfColumnsAt section: Int) -> Int
    func collectionViewLayout(_ layout: SectionCollectionViewLayout, cellAttributesForItemAt indexPath: IndexPath) -> SectionCellAttributes
    func collectionViewLayout(_ layout: SectionCollectionViewLayout, calculatedCellSizeForItemAt indexPath: IndexPath) -> CGSize
}

class SectionCollectionViewLayout: UICollectionViewLayout {
    private var cellLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    weak var delegate: SectionCollectionViewLayoutDelegate?
    
    private var collectionViewHeight: CGFloat = 0.0
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: collectionViewHeight)
    }
    
    fileprivate func extractedFunc(_ numberOfItems: Int, _ section: Int, _ delegate: SectionCollectionViewLayoutDelegate, _ columnWidths: inout [CGFloat], _ columnYPosition: inout [CGFloat], _ interitemSpacing: CGFloat, _ lastCellLayoutAttributesInColumn: inout [UICollectionViewLayoutAttributes]) {
        for index in 0 ..< numberOfItems {
            let indexPath = IndexPath(item: index, section: section)
            let cellAttributes = delegate.collectionViewLayout(self, cellAttributesForItemAt: indexPath)
            
            let sectionWidth = self.sectionWidthFor(section: section)
            let columWidth = cellAttributes.fractionalWidth * sectionWidth
            columnWidths[cellAttributes.column] = columWidth
            
            let origin = CGPoint(
                x: cellAttributes.column > 0 ? columnWidths[0 ..< cellAttributes.column].reduce(0, +) : 0.0,
                y: columnYPosition[cellAttributes.column]
            )
            
            let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = self.frameFor(cellAttributes: cellAttributes, at: indexPath, origin: origin)
            layoutAttributes.frame = frame
            
            columnYPosition[cellAttributes.column] = columnYPosition[cellAttributes.column] + layoutAttributes.size.height + interitemSpacing
            cellLayoutAttributes.append(layoutAttributes)
            lastCellLayoutAttributesInColumn[cellAttributes.column] = layoutAttributes
        }
    }
    
    override func prepare() {
        super.prepare()
        guard let delegate = delegate, let collectionView = collectionView else { return }
        let numberOfSections = collectionView.numberOfSections
        cellLayoutAttributes = []
        var sectionYPosition: CGFloat = 0.0
        
        for section in 0 ..< numberOfSections {
            let interitemSpacing = self.interitemSpacing(forSection: section)
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            let numberOfColumns = numberOfColumn(atSection: section)
            let sectionInset = inset(forSection: section)
            
            var lastCellLayoutAttributesInColumn: [UICollectionViewLayoutAttributes] = []
            var columnWidths: [CGFloat] = []
            var columnYPosition: [CGFloat] = []
            sectionYPosition += sectionInset.top
            
            for _ in 0 ..< numberOfColumns {
                columnWidths.append(0.0)
                columnYPosition.append(sectionYPosition)
                lastCellLayoutAttributesInColumn.append(UICollectionViewLayoutAttributes())
            }
            
            extractedFunc(numberOfItems, section, delegate, &columnWidths, &columnYPosition, interitemSpacing, &lastCellLayoutAttributesInColumn)
            
            let maxY = lastCellLayoutAttributesInColumn.map { $0.frame.maxY }.max() ?? 0.0
            lastCellLayoutAttributesInColumn.forEach {
                $0.frame.size.height += maxY - $0.frame.maxY
            }
            
            sectionYPosition = columnYPosition.max()! - interitemSpacing + sectionInset.bottom
            for index in 0 ..< columnYPosition.count {
                columnYPosition[index] = sectionYPosition
            }
            
            collectionViewHeight = sectionYPosition
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return (cellLayoutAttributes).filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellLayoutAttributes.first { $0.indexPath == indexPath }
    }
}

private extension SectionCollectionViewLayout {
    func frameFor(cellAttributes: SectionCellAttributes, at indexPath: IndexPath, origin: CGPoint) -> CGRect {
        let interitemSpacing = self.interitemSpacing(forSection: indexPath.section)
        let nodeSize = delegate?.collectionViewLayout(self, calculatedCellSizeForItemAt: indexPath) ?? .zero
        
        let sectionInset = inset(forSection: indexPath.section)
        let originX = origin.x + sectionInset.left + CGFloat(cellAttributes.column) * interitemSpacing
        return CGRect(x: originX, y: origin.y, width: nodeSize.width, height: nodeSize.height)
    }
    
    func sectionWidthFor(section: Int) -> CGFloat {
        guard let collectionViewWidth = delegate?.collectionViewSize.width else { return 0.0 }
        let inset = self.inset(forSection: section)
        let columnCounts = self.numberOfColumn(atSection: section)
        let totalInteritemSpacing = self.interitemSpacing(forSection: section) * CGFloat(columnCounts - 1)
        return collectionViewWidth - totalInteritemSpacing - inset.left - inset.right
    }
    
    func inset(forSection section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func interitemSpacing(forSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func numberOfColumn(atSection section: Int) -> Int {
        return delegate?.collectionViewLayout(self, numberOfColumnsAt: section) ?? 1
    }
}

class SectionCollectionViewLayoutInspector: NSObject, ASCollectionViewLayoutInspecting {
    func collectionView( _ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        guard let layout = collectionView.collectionViewLayout as? SectionCollectionViewLayout, let delegate = layout.delegate else { return ASSizeRangeZero }
        
        let cellAttributes = delegate.collectionViewLayout(layout, cellAttributesForItemAt: indexPath)
        let sectionWidth = layout.sectionWidthFor(section: indexPath.section)
        let cellWidth = cellAttributes.fractionalWidth * sectionWidth
        let maxCellSize = CGSize(width: cellWidth, height: CGFloat.greatestFiniteMagnitude)
        return ASSizeRangeMake(CGSize(width: cellWidth, height: 0.0), maxCellSize)
    }
    
    func scrollableDirections() -> ASScrollDirection {
        return ASScrollDirectionVerticalDirections
    }
}

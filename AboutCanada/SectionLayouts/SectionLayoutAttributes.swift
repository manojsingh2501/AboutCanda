//  Copyright © 2019 Cognizant. All rights reserved.

import UIKit

struct SectionCellAttributes {
    let column: Int
    let fractionalWidth: CGFloat
    let articleIndex: Int?
}

struct SectionAttributes {
    let cellAttributes: [SectionCellAttributes]
    let numberOfColumns: Int
    
    fileprivate init(layout: SectionLayoutDescription, articleIndexOffset: inout Int) {
        numberOfColumns = layout.columns.count
        cellAttributes = layout.columns.enumerated().compactMap { index, column in
            let articleIndex = articleIndexOffset
            articleIndexOffset += 1
            return SectionCellAttributes(
                column: index,
                fractionalWidth: column.fractionalWidth,
                articleIndex: articleIndex
            )
        }
    }
}

extension SectionAttributes {
    static func makeArticleGridLayoutWith(articles: Int, columns: Int) -> [SectionAttributes] {
        let sections = articles / columns
        let columnLayoutDescription = ColumnLayoutDescription(fractionalWidth: 1.0 / CGFloat(columns))
        var sectionLayoutDescriptions = Array(
            repeating: SectionLayoutDescription(columns: Array(repeating: columnLayoutDescription, count: columns)),
            count: sections
        )
        
        let bottomSectionColums = articles % columns
        if bottomSectionColums > 0 {
            let bottomColumnLayoutDescription = ColumnLayoutDescription(fractionalWidth: 1.0 / CGFloat(bottomSectionColums))
            sectionLayoutDescriptions += [SectionLayoutDescription(columns: Array(repeating: bottomColumnLayoutDescription, count: bottomSectionColums))]
        }
        
        var articleIndexOffset: Int = 0
        return sectionLayoutDescriptions.map { layout in
            SectionAttributes(layout: layout, articleIndexOffset: &articleIndexOffset)
        }
    }
}

extension Array where Element == SectionAttributes {
    func cellAttributes(at indexPath: IndexPath) -> SectionCellAttributes {
        return self[indexPath.section].cellAttributes[indexPath.item]
    }
}

private struct SectionLayoutDescription {
    let columns: [ColumnLayoutDescription]
    init(columns: [ColumnLayoutDescription]) {
        self.columns = columns
    }
}

private struct ColumnLayoutDescription {
    let fractionalWidth: CGFloat
}

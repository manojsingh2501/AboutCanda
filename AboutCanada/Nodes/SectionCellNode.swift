//  Copyright © 2019 Cognizant. All rights reserved.

import UIKit
import AsyncDisplayKit

class SectionCellNode: ASCellNode {
    private let exonym: Country.Exonym
    
    private let dividerNode = DividerNode(color: Colors.separator)
    private let imageNode = ASNetworkImageNode()
    private let titleNode = ASTextNode()
    private let descriptionNode = ASTextNode()
    private let typography = Typography()
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = Colors.sectionCellHighlited
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.backgroundColor = .white
                }
            }
        }
    }
    
    init(exonym: Country.Exonym) {
        self.exonym = exonym
        super.init()
        
        dividerNode.style.spacingBefore = LayoutConstant.verticalPadding
        imageNode.backgroundColor = Colors.genericGray
        imageNode.contentMode = .scaleAspectFill
        selectionStyle = .none
        automaticallyManagesSubnodes = true
        prepareNodes()
        
        neverShowPlaceholders = true
        backgroundColor = .white
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        func makeFlexSpec() -> ASLayoutSpec {
            let spec = ASLayoutSpec()
            spec.style.flexGrow = 1.0
            return spec
        }
        
        let textLayoutSpec = ASStackLayoutSpec.vertical()
        textLayoutSpec.alignItems = .start
        
        let textSpecChildren: [ASLayoutElement] = [titleNode, descriptionNode, makeFlexSpec()]
        let horizontalLayoutSpec = ASStackLayoutSpec.horizontal()
        let insetLayoutSpec: ASLayoutSpec
        
        if exonym.imageURL != nil {
            let imageWidth = constrainedSize.max.width
            imageNode.style.preferredSize = CGSize(width: imageWidth, height: imageWidth / LayoutConstant.articleImageRatio)
            let imageInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 6.0, right: 0.0), child: imageNode)
            
            textLayoutSpec.children = [imageInsetLayoutSpec] + textSpecChildren
            insetLayoutSpec = ASInsetLayoutSpec(insets: .zero, child: textLayoutSpec)
            insetLayoutSpec.style.flexBasis = ASDimensionMakeWithFraction(1.0)
            horizontalLayoutSpec.children = [insetLayoutSpec, makeFlexSpec()]
        } else {
            textLayoutSpec.children = textSpecChildren
            insetLayoutSpec = ASInsetLayoutSpec(insets: .zero, child: textLayoutSpec)
            insetLayoutSpec.style.flexBasis = ASDimensionMakeWithFraction(1.0)
            horizontalLayoutSpec.children = [insetLayoutSpec]
        }
        
        insetLayoutSpec.style.flexGrow = 1.0
        insetLayoutSpec.style.alignSelf = .stretch
        
        horizontalLayoutSpec.style.flexGrow = 1.0
        
        let verticalLayoutSpec = ASStackLayoutSpec.vertical()
        verticalLayoutSpec.children = [horizontalLayoutSpec, dividerNode]
        verticalLayoutSpec.alignItems = .stretch
        verticalLayoutSpec.justifyContent = .spaceBetween
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 4.0, left: 8.0, bottom: 1.0, right: 8.0), child: verticalLayoutSpec)
    }
}

private extension SectionCellNode {
    func prepareNodes() {
        imageNode.setURL(exonym.imageURL, resetToDefault: true)
        titleNode.attributedText = NSAttributedString(
            string: exonym.title ?? "",
            attributes: [
                .font: typography.primaryBoldFont(ofSize: 22.0),
                .foregroundColor: Colors.titleText
            ]
        )
        
        let standfirstAttributedString = NSAttributedString(
            string: exonym.description ?? "",
            attributes: [
                .foregroundColor: Colors.descriptionText,
                .font: typography.primaryFont(ofSize: 16.0),
            ]
        )
        
        descriptionNode.attributedText = standfirstAttributedString
    }
}

class DividerNode: ASDisplayNode {
    let width: CGFloat
    let height: CGFloat
    
    init(width: CGFloat = 0.0, height: CGFloat = 1.0, color: UIColor = Colors.separator) {
        self.width = width
        self.height = height
        super.init()
        
        backgroundColor = color
        isLayerBacked = true
        style.preferredSize = CGSize(width: width, height: height)
    }
}

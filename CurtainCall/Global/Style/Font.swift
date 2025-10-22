//
//  Font.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit

struct CCFont {
    // MARK: - Font Scale
    
    // Large Title
    static let largeTitle: CGFloat = 34
    
    // Title
    static let title1: CGFloat = 28
    static let title2: CGFloat = 22
    static let title3: CGFloat = 20
    
    // Headline
    static let headline: CGFloat = 17
    
    // Body
    static let body: CGFloat = 17
    
    // Callout
    static let callout: CGFloat = 16
    
    // Subhead
    static let subheadline: CGFloat = 15
    static let subheadline2: CGFloat = 13
    
    // Footnote
    static let footnote: CGFloat = 11
    
    // Caption
    static let caption1: CGFloat = 10
    static let caption2: CGFloat = 9
}

// MARK: - NanumSquare Font Helper
extension UIFont {
    static func nanumSquare(size: CGFloat, isBold: Bool = false) -> UIFont {
        let fontName = isBold ? CCStrings.FontName.nanumSquareBold : CCStrings.FontName.nanumSquareRegular
        return UIFont(name: fontName, size: size) ?? systemFont(ofSize: size)
    }
}

// MARK: - App Font
extension UIFont {
    // Regular fonts
    static var ccLargeTitle: UIFont { nanumSquare(size: CCFont.largeTitle) }
    static var ccTitle1: UIFont { nanumSquare(size: CCFont.title1) }
    static var ccTitle2: UIFont { nanumSquare(size: CCFont.title2) }
    static var ccTitle3: UIFont { nanumSquare(size: CCFont.title3) }
    static var ccHeadline: UIFont { nanumSquare(size: CCFont.headline) }
    static var ccBody: UIFont { nanumSquare(size: CCFont.body) }
    static var ccCallout: UIFont { nanumSquare(size: CCFont.callout) }
    static var ccSubheadline: UIFont { nanumSquare(size: CCFont.subheadline) }
    static var ccSubheadline2: UIFont { nanumSquare(size: CCFont.subheadline2) }
    static var ccFootnote: UIFont { nanumSquare(size: CCFont.footnote) }
    static var ccCaption1: UIFont { nanumSquare(size: CCFont.caption1) }
    static var ccCaption2: UIFont { nanumSquare(size: CCFont.caption2) }
    
    // Bold fonts
    static var ccLargeTitleBold: UIFont { nanumSquare(size: CCFont.largeTitle, isBold: true) }
    static var ccTitle1Bold: UIFont { nanumSquare(size: CCFont.title1, isBold: true) }
    static var ccTitle2Bold: UIFont { nanumSquare(size: CCFont.title2, isBold: true) }
    static var ccTitle3Bold: UIFont { nanumSquare(size: CCFont.title3, isBold: true) }
    static var ccHeadlineBold: UIFont { nanumSquare(size: CCFont.headline, isBold: true) }
    static var ccBodyBold: UIFont { nanumSquare(size: CCFont.body, isBold: true) }
    static var ccCalloutBold: UIFont { nanumSquare(size: CCFont.callout, isBold: true) }
    static var ccSubheadlineBold: UIFont { nanumSquare(size: CCFont.subheadline, isBold: true) }
    static var ccSubheadlineBold2: UIFont { nanumSquare(size: CCFont.subheadline2, isBold: true) }
    static var ccFootnoteBold: UIFont { nanumSquare(size: CCFont.footnote, isBold: true) }
    static var ccCaption1Bold: UIFont { nanumSquare(size: CCFont.caption1, isBold: true) }
    static var ccCaption2Bold: UIFont { nanumSquare(size: CCFont.caption2, isBold: true) }
}

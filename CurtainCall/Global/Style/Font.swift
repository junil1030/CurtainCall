//
//  Font.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit

struct AppFont {
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
    
    // Footnote
    static let footnote: CGFloat = 13
    
    // Caption
    static let caption1: CGFloat = 12
    static let caption2: CGFloat = 11
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
    static var ccLargeTitle: UIFont { nanumSquare(size: AppFont.largeTitle) }
    static var ccTitle1: UIFont { nanumSquare(size: AppFont.title1) }
    static var ccTitle2: UIFont { nanumSquare(size: AppFont.title2) }
    static var ccTitle3: UIFont { nanumSquare(size: AppFont.title3) }
    static var ccHeadline: UIFont { nanumSquare(size: AppFont.headline) }
    static var ccBody: UIFont { nanumSquare(size: AppFont.body) }
    static var ccCallout: UIFont { nanumSquare(size: AppFont.callout) }
    static var ccSubheadline: UIFont { nanumSquare(size: AppFont.subheadline) }
    static var ccFootnote: UIFont { nanumSquare(size: AppFont.footnote) }
    static var ccCaption1: UIFont { nanumSquare(size: AppFont.caption1) }
    static var ccCaption2: UIFont { nanumSquare(size: AppFont.caption2) }
    
    // Bold fonts
    static var ccLargeTitleBold: UIFont { nanumSquare(size: AppFont.largeTitle, isBold: true) }
    static var ccTitle1Bold: UIFont { nanumSquare(size: AppFont.title1, isBold: true) }
    static var ccTitle2Bold: UIFont { nanumSquare(size: AppFont.title2, isBold: true) }
    static var ccTitle3Bold: UIFont { nanumSquare(size: AppFont.title3, isBold: true) }
    static var ccHeadlineBold: UIFont { nanumSquare(size: AppFont.headline, isBold: true) }
    static var ccBodyBold: UIFont { nanumSquare(size: AppFont.body, isBold: true) }
    static var ccCalloutBold: UIFont { nanumSquare(size: AppFont.callout, isBold: true) }
    static var ccSubheadlineBold: UIFont { nanumSquare(size: AppFont.subheadline, isBold: true) }
    static var ccFootnoteBold: UIFont { nanumSquare(size: AppFont.footnote, isBold: true) }
    static var ccCaption1Bold: UIFont { nanumSquare(size: AppFont.caption1, isBold: true) }
    static var ccCaption2Bold: UIFont { nanumSquare(size: AppFont.caption2, isBold: true) }
}

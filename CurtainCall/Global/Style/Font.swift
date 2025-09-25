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
        let fontName = isBold ? AppStrings.FontName.nanumSquareBold : AppStrings.FontName.nanumSquareRegular
        return UIFont(name: fontName, size: size) ?? systemFont(ofSize: size)
    }
}

// MARK: - App Font
extension UIFont {
    // Regular fonts
    static var appLargeTitle: UIFont { nanumSquare(size: AppFont.largeTitle) }
    static var appTitle1: UIFont { nanumSquare(size: AppFont.title1) }
    static var appTitle2: UIFont { nanumSquare(size: AppFont.title2) }
    static var appTitle3: UIFont { nanumSquare(size: AppFont.title3) }
    static var appHeadline: UIFont { nanumSquare(size: AppFont.headline) }
    static var appBody: UIFont { nanumSquare(size: AppFont.body) }
    static var appCallout: UIFont { nanumSquare(size: AppFont.callout) }
    static var appSubheadline: UIFont { nanumSquare(size: AppFont.subheadline) }
    static var appFootnote: UIFont { nanumSquare(size: AppFont.footnote) }
    static var appCaption1: UIFont { nanumSquare(size: AppFont.caption1) }
    static var appCaption2: UIFont { nanumSquare(size: AppFont.caption2) }
    
    // Bold fonts
    static var appLargeTitleBold: UIFont { nanumSquare(size: AppFont.largeTitle, isBold: true) }
    static var appTitle1Bold: UIFont { nanumSquare(size: AppFont.title1, isBold: true) }
    static var appTitle2Bold: UIFont { nanumSquare(size: AppFont.title2, isBold: true) }
    static var appTitle3Bold: UIFont { nanumSquare(size: AppFont.title3, isBold: true) }
    static var appHeadlineBold: UIFont { nanumSquare(size: AppFont.headline, isBold: true) }
    static var appBodyBold: UIFont { nanumSquare(size: AppFont.body, isBold: true) }
    static var appCalloutBold: UIFont { nanumSquare(size: AppFont.callout, isBold: true) }
    static var appSubheadlineBold: UIFont { nanumSquare(size: AppFont.subheadline, isBold: true) }
    static var appFootnoteBold: UIFont { nanumSquare(size: AppFont.footnote, isBold: true) }
    static var appCaption1Bold: UIFont { nanumSquare(size: AppFont.caption1, isBold: true) }
    static var appCaption2Bold: UIFont { nanumSquare(size: AppFont.caption2, isBold: true) }
}

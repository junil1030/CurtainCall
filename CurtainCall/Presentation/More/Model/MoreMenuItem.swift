//
//  MoreMenuItem.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit

enum MoreMenuItem: CaseIterable {
    case privacyPolicy
    case openSourceLicense
    case contact
    case appStoreReview
    
    var title: String {
        switch self {
        case .privacyPolicy:
            return "개인정보 처리방침"
        case .openSourceLicense:
            return "오픈소스 라이선스"
        case .contact:
            return "문의하기"
        case .appStoreReview:
            return "앱스토어 리뷰"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .privacyPolicy:
            return UIImage(systemName: "shield.lefthalf.filled")
        case .openSourceLicense:
            return UIImage(systemName: "doc.text")
        case .contact:
            return UIImage(systemName: "envelope")
        case .appStoreReview:
            return UIImage(systemName: "star")
        }
    }
}

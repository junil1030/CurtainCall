//
//  ToastType.swift
//  CurtainCall
//
//  Created by 서준일 on 11/9/25.
//

import UIKit

enum ToastType {
    case success
    case error
    case info
    case warning
    
    var backgroundColor: UIColor {
        switch self {
        case .success:
            return UIColor.systemGreen.withAlphaComponent(0.9)
        case .error:
            return UIColor.systemRed.withAlphaComponent(0.9)
        case.info:
            return UIColor.systemBlue.withAlphaComponent(0.9)
        case .warning:
            return UIColor.systemOrange.withAlphaComponent(0.9)
        }
    }
    
    var textColor: UIColor {
        return .white
    }
    
    var icon: String? {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        }
    }
}

//
//  CompanionType.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

enum CompanionType: String, CaseIterable {
    case alone = "혼자"
    case friend = "친구"
    case family = "가족"
    case lover = "연인"
    
    var displayName: String {
        return self.rawValue
    }
    
    var emoji: String {
        switch self {
        case .alone: return "👤"
        case .friend: return "👭"
        case .family: return "👨‍👩‍👧‍👦"
        case .lover: return "💑"
        }
    }
}

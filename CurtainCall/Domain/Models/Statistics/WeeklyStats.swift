//
//  WeeklyStats.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

/// 주차별 통계
struct WeeklyStats: Hashable {
    let weekNumber: Int              // 1주차, 2주차, ...
    let count: Int
    
    var displayName: String {
        return "\(weekNumber)주"
    }
}

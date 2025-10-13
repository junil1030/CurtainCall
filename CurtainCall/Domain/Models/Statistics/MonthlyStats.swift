//
//  MonthlyStats.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

/// 월별 통계
struct MonthlyStats: Hashable {
    let month: Int                   // 1 ~ 12
    let count: Int
    
    var displayName: String {
        return "\(month)월"
    }
}

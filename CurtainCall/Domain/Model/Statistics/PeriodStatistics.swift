//
//  PeriodStatistics.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

/// 기간별 통계 요약
struct PeriodStatistics {
    let totalCount: Int              // 해당 기간 총 관람 횟수
    let averageRating: Double        // 평균 평점
    let previousCount: Int           // 이전 기간 관람 횟수
    
    var changePercentage: Double {
        guard previousCount > 0 else { return 0 }
        return Double(totalCount - previousCount) / Double(previousCount) * 100
    }
    
    var changeCount: Int {
        return totalCount - previousCount
    }
}

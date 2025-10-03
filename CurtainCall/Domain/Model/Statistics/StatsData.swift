//
//  StatsData.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

struct StatsData {
    let period: StatsPeriod
    let summary: StatsSummary
    let trendData: [TrendDataPoint]
    let genreStats: [GenreStats]
    let companionStats: [CompanionStats]
    let areaStats: [AreaStats]
}

/// 통계 요약 정보
struct StatsSummary {
    let currentCount: Int           // 이번 주/달/해 관람 횟수
    let changeCount: Int            // 지난 기간 대비 변화량 (±)
    let averageRating: Double       // 평균 평점
    let specialInfo: String         // 최다 요일/장르/달
    
    var changePercentage: Double {
        guard changeCount != 0 else { return 0 }
        let previousCount = currentCount - changeCount
        guard previousCount > 0 else { return 0 }
        return Double(changeCount) / Double(previousCount) * 100
    }
    
    var isIncrease: Bool {
        return changeCount > 0
    }
}

/// 트렌드 차트용 데이터 포인트
struct TrendDataPoint: Hashable {
    let label: String               // "월", "1주", "1월" 등
    let count: Int
    let index: Int                  // 정렬을 위한 인덱스
}

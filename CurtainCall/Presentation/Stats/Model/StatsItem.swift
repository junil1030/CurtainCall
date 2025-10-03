//
//  StatsItem.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

enum StatsItem: Hashable {
    case summary(StatsSummaryItem)
    case trend(TrendChartItem)
    case genre(GenreAnalysisItem)
    case companion(CompanionItem)
    case area(AreaItem)
}

// MARK: - Item Models

/// 통계 요약 아이템
struct StatsSummaryItem: Hashable {
    let period: StatsPeriod
    let currentCount: Int
    let changeCount: Int
    let changePercentage: Double
    let averageRating: Double
    let specialInfoTitle: String    // "최다 요일", "최다 장르", "최다 관람 달"
    let specialInfoValue: String    // "토", "뮤지컬", "5월"
    
    var isIncrease: Bool {
        return changeCount > 0
    }
    
    var changeText: String {
        let prefix = changeCount >= 0 ? "+" : ""
        return "\(prefix)\(changeCount)"
    }
}

/// 트렌드 차트 아이템
struct TrendChartItem: Hashable {
    let period: StatsPeriod
    let dataPoints: [TrendDataPoint]
}

/// 장르 분석 아이템
struct GenreAnalysisItem: Hashable {
    let genre: String
    let count: Int
    let percentage: Double
    
    var percentageText: String {
        return String(format: "%.1f%%", percentage)
    }
}

/// 동행인 아이템
struct CompanionItem: Hashable {
    let companion: String
    let count: Int
    let emoji: String
    
    init(companion: String, count: Int) {
        self.companion = companion
        self.count = count
        
        // CompanionType enum에서 emoji 가져오기
        if let companionType = CompanionType(rawValue: companion) {
            self.emoji = companionType.emoji
        } else {
            self.emoji = "👥"
        }
    }
}

/// 지역 아이템
struct AreaItem: Hashable {
    let area: String
    let count: Int
    let rank: Int
}

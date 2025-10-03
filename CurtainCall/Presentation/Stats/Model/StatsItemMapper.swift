//
//  StatsItemMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

struct StatsItemMapper {
    
    // StatsData를 Presentation Item들로 변환
    static func mapToItems(from data: StatsData) -> [StatsSection: [StatsItem]] {
        var items: [StatsSection: [StatsItem]] = [:]
        
        // 1. Summary Section
        let summaryItem = mapToSummaryItem(from: data.summary, period: data.period)
        items[.summary] = [.summary(summaryItem)]
        
        // 2. Trend Section
        let trendItem = mapToTrendItem(from: data.trendData, period: data.period)
        items[.trend] = [.trend(trendItem)]
        
        // 3. Genre Section
        let genreItems = mapToGenreItems(from: data.genreStats)
        items[.genre] = genreItems
        
        // 4. Companion Section
        let companionItems = mapToCompanionItems(from: data.companionStats)
        items[.companion] = companionItems
        
        // 5. Area Section
        let areaItems = mapToAreaItems(from: data.areaStats)
        items[.area] = areaItems
        
        return items
    }
    
    // MARK: - Private Mapping Methods
    
    private static func mapToSummaryItem(from summary: StatsSummary, period: StatsPeriod) -> StatsSummaryItem {
        let specialInfoTitle: String
        switch period {
        case .weekly:
            specialInfoTitle = "최다 요일"
        case .monthly:
            specialInfoTitle = "최다 장르"
        case .yearly:
            specialInfoTitle = "최다 관람 달"
        }
        
        return StatsSummaryItem(
            period: period,
            currentCount: summary.currentCount,
            changeCount: summary.changeCount,
            changePercentage: summary.changePercentage,
            averageRating: summary.averageRating,
            specialInfoTitle: specialInfoTitle,
            specialInfoValue: summary.specialInfo
        )
    }
    
    private static func mapToTrendItem(from dataPoints: [TrendDataPoint], period: StatsPeriod) -> TrendChartItem {
        return TrendChartItem(
            period: period,
            dataPoints: dataPoints.sorted { $0.index < $1.index }
        )
    }
    
    private static func mapToGenreItems(from genreStats: [GenreStats]) -> [StatsItem] {
        return genreStats.map { stat in
            let item = GenreAnalysisItem(
                genre: stat.genre,
                count: stat.count,
                percentage: stat.percentage
            )
            return .genre(item)
        }
    }
    
    private static func mapToCompanionItems(from companionStats: [CompanionStats]) -> [StatsItem] {
        return companionStats.map { stat in
            let item = CompanionItem(
                companion: stat.companion,
                count: stat.count
            )
            return .companion(item)
        }
    }
    
    private static func mapToAreaItems(from areaStats: [AreaStats]) -> [StatsItem] {
        return areaStats.enumerated().map { index, stat in
            let item = AreaItem(
                area: stat.area,
                count: stat.count,
                rank: index + 1
            )
            return .area(item)
        }
    }
}

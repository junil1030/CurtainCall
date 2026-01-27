//
//  FetchStatsUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

final class FetchStatsUseCase: UseCase {

    // MARK: - Input
    struct Input {
        let period: StatsPeriod
        let date: Date

        init(period: StatsPeriod, date: Date = Date()) {
            self.period = period
            self.date = date
        }
    }

    // MARK: - Typealias
    typealias Output = StatsData

    // MARK: - Properties
    private let repository: ViewingRecordRepositoryProtocol

    // MARK: - Init
    init(repository: ViewingRecordRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ input: Input) -> StatsData {
        let (startDate, endDate) = DateCalculator.dateRange(for: input.period, from: input.date)

        // 1. 요약 정보 생성
        let summary = createSummary(for: input.period, startDate: startDate, endDate: endDate)

        // 2. 트렌드 데이터 생성
        let trendData = createTrendData(for: input.period, startDate: startDate, endDate: endDate)
        
        // 3. 장르별 통계
        let genreStats = repository.getGenreStats(from: startDate, to: endDate)
        
        // 4. 동행인별 통계
        let companionStats = repository.getCompanionStats(from: startDate, to: endDate)
        
        // 5. 지역별 통계
        let areaStats = repository.getAreaStats(from: startDate, to: endDate)
        
        return StatsData(
            period: input.period,
            summary: summary,
            trendData: trendData,
            genreStats: genreStats,
            companionStats: companionStats,
            areaStats: areaStats
        )
    }
    
    // MARK: - Private Methods
    
    // 요약 정보 생성
    private func createSummary(for period: StatsPeriod, startDate: Date, endDate: Date) -> StatsSummary {
        let periodStats = repository.getStatsByPeriod(from: startDate, to: endDate)
        
        let currentCount = periodStats.totalCount
        let changeCount = periodStats.changeCount
        let averageRating = periodStats.averageRating
        
        // 특별 정보 (최다 요일/장르/달)
        let specialInfo: String
        switch period {
        case .weekly:
            let mostWeekday = repository.getMostFrequentWeekday(from: startDate, to: endDate)
            specialInfo = mostWeekday ?? "-"
            
        case .monthly:
            let mostGenre = repository.getMostFrequentGenre(from: startDate, to: endDate)
            specialInfo = mostGenre ?? "-"
            
        case .yearly:
            let mostMonth = repository.getMostFrequentMonth(from: startDate, to: endDate)
            specialInfo = mostMonth ?? "-"
        }
        
        return StatsSummary(
            currentCount: currentCount,
            changeCount: changeCount,
            averageRating: averageRating,
            specialInfo: specialInfo
        )
    }
    
    // 트렌드 데이터 생성
    private func createTrendData(for period: StatsPeriod, startDate: Date, endDate: Date) -> [TrendDataPoint] {
        switch period {
        case .weekly:
            let weekdayStats = repository.getWeekdayStats(from: startDate, to: endDate)
            return weekdayStats.map { stat in
                TrendDataPoint(
                    label: stat.weekday,
                    count: stat.count,
                    index: stat.weekdayIndex
                )
            }
            
        case .monthly:
            let weeklyStats = repository.getWeeklyStats(from: startDate, to: endDate)
            return weeklyStats.map { stat in
                TrendDataPoint(
                    label: stat.displayName,
                    count: stat.count,
                    index: stat.weekNumber
                )
            }
            
        case .yearly:
            let monthlyStats = repository.getMonthlyStats(from: startDate, to: endDate)
            return monthlyStats.map { stat in
                TrendDataPoint(
                    label: stat.displayName,
                    count: stat.count,
                    index: stat.month
                )
            }
        }
    }
}

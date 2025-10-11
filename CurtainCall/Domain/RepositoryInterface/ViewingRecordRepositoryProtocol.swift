//
//  ViewingRecordRepositoryProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation

protocol ViewingRecordRepositoryProtocol {
    // Create
    func addRecord(_ record: ViewingRecord) throws
    
    // Read
    func getRecords() -> [ViewingRecord]
    func getRecordsByDate(from: Date, to: Date) -> [ViewingRecord]
    func getRecordsByPerformance(performanceId: String) -> [ViewingRecord]
    func getRecordCount() -> Int
    func getRecord(by id: String) -> ViewingRecord?
    
    // Update
    func updateRecord(_ record: ViewingRecord) throws
    func updateRating(id: String, rating: Int) throws
    func updateMemo(id: String, memo: String) throws
    func updateRecordFields(id: String, viewingDate: Date, companion: String, seat: String, rating: Int, memo: String) throws
    
    // Delete
    func deleteRecord(id: String) throws
    func deleteAllRecords() throws
    
    // Statistics
    func getStatistics() -> ViewingStatistics
    
    // MARK: - Statistics for Stats Screen
    /// 기간별 통계 데이터 조회
    func getStatsByPeriod(from startDate: Date, to endDate: Date) -> PeriodStatistics
    
    /// 요일별 관람 횟수 조회 (주간 트렌드용)
    func getWeekdayStats(from startDate: Date, to endDate: Date) -> [WeekdayStats]
    
    /// 주차별 관람 횟수 조회 (월간 트렌드용)
    func getWeeklyStats(from startDate: Date, to endDate: Date) -> [WeeklyStats]
    
    /// 월별 관람 횟수 조회 (연간 트렌드용)
    func getMonthlyStats(from startDate: Date, to endDate: Date) -> [MonthlyStats]
    
    /// 장르별 관람 횟수 조회
    func getGenreStats(from startDate: Date, to endDate: Date) -> [GenreStats]
    
    /// 동행인별 관람 횟수 조회
    func getCompanionStats(from startDate: Date, to endDate: Date) -> [CompanionStats]
    
    /// 지역별 관람 횟수 조회
    func getAreaStats(from startDate: Date, to endDate: Date) -> [AreaStats]
    
    /// 최다 요일 조회 (주간용)
    func getMostFrequentWeekday(from startDate: Date, to endDate: Date) -> String?
    
    /// 최다 장르 조회 (월간용)
    func getMostFrequentGenre(from startDate: Date, to endDate: Date) -> String?
    
    /// 최다 관람 월 조회 (연간용)
    func getMostFrequentMonth(from startDate: Date, to endDate: Date) -> String?
}

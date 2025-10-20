//
//  ViewingRecordRepository.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import Foundation
import RealmSwift
import OSLog

final class ViewingRecordRepository: ViewingRecordRepositoryProtocol {
    
    // MARK: - Properties
    private let realmManager = RealmManager.shared
    
    // MARK: - Create
    func addRecord(_ record: ViewingRecord) throws {
        do {
            try realmManager.write { realm in
                realm.add(record)
                Logger.data.info("관람 기록 추가 성공: \(record.title)")
            }
        } catch {
            Logger.data.error("관람 기록 추가 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Read
    func getRecords() -> [ViewingRecord] {
        do {
            let realm = try realmManager.getRealm()
            let records = realm.objects(ViewingRecord.self)
                .sorted(byKeyPath: "viewingDate", ascending: false)
            
            return Array(records)
        } catch {
            Logger.data.error("관람 기록 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getRecordsByDate(from startDate: Date, to endDate: Date) -> [ViewingRecord] {
        do {
            let realm = try realmManager.getRealm()
            let records = realm.objects(ViewingRecord.self)
                .filter("viewingDate >= %@ AND viewingDate <= %@", startDate, endDate)
                .sorted(byKeyPath: "viewingDate", ascending: false)
            
            return Array(records)
        } catch {
            Logger.data.error("날짜별 관람 기록 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getRecordsByPerformance(performanceId: String) -> [ViewingRecord] {
        do {
            let realm = try realmManager.getRealm()
            let records = realm.objects(ViewingRecord.self)
                .filter("performanceId == %@", performanceId)
                .sorted(byKeyPath: "viewingDate", ascending: false)
            
            return Array(records)
        } catch {
            Logger.data.error("공연별 관람 기록 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getRecordCount() -> Int {
        do {
            let realm = try realmManager.getRealm()
            return realm.objects(ViewingRecord.self).count
        } catch {
            Logger.data.error("관람 기록 개수 조회 실패: \(error.localizedDescription)")
            return 0
        }
    }
    
    func getRecord(by id: String) -> ViewingRecord? {
        do {
            guard let objectId = try? ObjectId(string: id) else {
                Logger.data.error("유효하지 않은 ID: \(id)")
                return nil
            }
            
            let realm = try realmManager.getRealm()
            return realm.object(ofType: ViewingRecord.self, forPrimaryKey: objectId)
        } catch {
            Logger.data.error("관람 기록 단건 조회 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Update
    func updateRecord(_ record: ViewingRecord) throws {
        do {
            try realmManager.write { realm in
                record.updatedAt = Date()
                realm.add(record, update: .modified)
                Logger.data.info("관람 기록 수정 성공: \(record.title)")
            }
        } catch {
            Logger.data.error("관람 기록 수정 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateRating(id: String, rating: Int) throws {
        guard rating >= 0 && rating <= 5 else {
            throw NSError(domain: "ViewingRecordRepository", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "별점은 0~5 사이여야 합니다."
            ])
        }
        
        do {
            guard let objectId = try? ObjectId(string: id) else {
                throw NSError(domain: "ViewingRecordRepository", code: -3, userInfo: [
                    NSLocalizedDescriptionKey: "유효하지 않은 ID 형식입니다."
                ])
            }
            
            try realmManager.write { realm in
                guard let record = realm.object(ofType: ViewingRecord.self, forPrimaryKey: objectId) else {
                    throw NSError(domain: "ViewingRecordRepository", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "해당 ID의 관람 기록을 찾을 수 없습니다."
                    ])
                }
                
                record.rating = rating
                record.updatedAt = Date()
                Logger.data.info("별점 수정 성공: \(record.title) - \(rating)점")
            }
        } catch {
            Logger.data.error("별점 수정 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateMemo(id: String, memo: String) throws {
        do {
            guard let objectId = try? ObjectId(string: id) else {
                throw NSError(domain: "ViewingRecordRepository", code: -3, userInfo: [
                    NSLocalizedDescriptionKey: "유효하지 않은 ID 형식입니다."
                ])
            }
            
            try realmManager.write { realm in
                guard let record = realm.object(ofType: ViewingRecord.self, forPrimaryKey: objectId) else {
                    throw NSError(domain: "ViewingRecordRepository", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "해당 ID의 관람 기록을 찾을 수 없습니다."
                    ])
                }
                
                record.memo = memo
                record.updatedAt = Date()
                Logger.data.info("메모 수정 성공: \(record.title)")
            }
        } catch {
            Logger.data.error("메모 수정 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateRecordFields(id: String, viewingDate: Date, companion: String, seat: String, rating: Int, memo: String) throws {
        do {
            guard let objectId = try? ObjectId(string: id) else {
                throw NSError(domain: "ViewingRecordRepository", code: -3, userInfo: [
                    NSLocalizedDescriptionKey: "유효하지 않은 ID 형식입니다."
                ])
            }
            
            try realmManager.write { realm in
                guard let record = realm.object(ofType: ViewingRecord.self, forPrimaryKey: objectId) else {
                    throw NSError(domain: "ViewingRecordRepository", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "해당 ID의 관람 기록을 찾을 수 없습니다."
                    ])
                }
                
                record.viewingDate = viewingDate
                record.companion = companion
                record.seat = seat
                record.rating = rating
                record.memo = memo
                record.updatedAt = Date()
                
                Logger.data.info("관람 기록 필드 수정 성공: \(record.title)")
            }
        } catch {
            Logger.data.error("관람 기록 필드 수정 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Delete
    func deleteRecord(id: String) throws {
        do {
            guard let objectId = try? ObjectId(string: id) else {
                throw NSError(domain: "ViewingRecordRepository", code: -3, userInfo: [
                    NSLocalizedDescriptionKey: "유효하지 않은 ID 형식입니다."
                ])
            }
            
            try realmManager.write { realm in
                guard let record = realm.object(ofType: ViewingRecord.self, forPrimaryKey: objectId) else {
                    throw NSError(domain: "ViewingRecordRepository", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "해당 ID의 관람 기록을 찾을 수 없습니다."
                    ])
                }
                
                let title = record.title
                realm.delete(record)
                Logger.data.info("관람 기록 삭제 성공: \(title)")
            }
        } catch {
            Logger.data.error("관람 기록 삭제 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteAllRecords() throws {
        do {
            try realmManager.write { realm in
                let records = realm.objects(ViewingRecord.self)
                realm.delete(records)
                Logger.data.info("모든 관람 기록 삭제 성공")
            }
        } catch {
            Logger.data.error("모든 관람 기록 삭제 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Statistics
    func getStatistics() -> ViewingStatistics {
        do {
            let realm = try realmManager.getRealm()
            let records = realm.objects(ViewingRecord.self)
            
            let totalCount = records.count
            let ratedRecords = records.filter("rating > 0")
            let totalRating: Int = ratedRecords.sum(ofProperty: "rating")
            let averageRating = ratedRecords.isEmpty ? 0.0 : Double(totalRating) / Double(ratedRecords.count)
            
            // 장르별 통계
            var genreCount: [String: Int] = [:]
            for record in records {
                let displayName = convertGenreToDisplayName(record.genre)
                genreCount[displayName, default: 0] += 1
            }
            
            return ViewingStatistics(
                totalCount: totalCount,
                averageRating: averageRating,
                genreCount: genreCount
            )
        } catch {
            Logger.data.error("통계 조회 실패: \(error.localizedDescription)")
            return ViewingStatistics(totalCount: 0, averageRating: 0.0, genreCount: [:])
        }
    }
}

extension ViewingRecordRepository {
    
    // MARK: - Statistics for Stats Screen
    
    func getStatsByPeriod(from startDate: Date, to endDate: Date) -> PeriodStatistics {
        do {
            let realm = try realmManager.getRealm()
            
            // 현재 기간 데이터
            let currentRecords = realm.objects(ViewingRecord.self)
                .filter("viewingDate >= %@ AND viewingDate <= %@", startDate, endDate)
            
            let totalCount = currentRecords.count
            let ratedRecords = currentRecords.filter("rating > 0")
            let totalRating: Int = ratedRecords.sum(ofProperty: "rating")
            let averageRating = ratedRecords.isEmpty ? 0.0 : Double(totalRating) / Double(ratedRecords.count)
            
            // 이전 기간 데이터 (기간 차이 계산)
            let calendar = Calendar.current
            let daysDifference = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            let previousStartDate = calendar.date(byAdding: .day, value: -(daysDifference + 1), to: startDate) ?? startDate
            let previousEndDate = calendar.date(byAdding: .day, value: -1, to: startDate) ?? startDate
            
            let previousRecords = realm.objects(ViewingRecord.self)
                .filter("viewingDate >= %@ AND viewingDate <= %@", previousStartDate, previousEndDate)
            let previousCount = previousRecords.count
            
            return PeriodStatistics(
                totalCount: totalCount,
                averageRating: averageRating,
                previousCount: previousCount
            )
        } catch {
            Logger.data.error("기간별 통계 조회 실패: \(error.localizedDescription)")
            return PeriodStatistics(totalCount: 0, averageRating: 0.0, previousCount: 0)
        }
    }
    
    func getWeekdayStats(from startDate: Date, to endDate: Date) -> [WeekdayStats] {
        do {
            let realm = try realmManager.getRealm()
            let records = realm.objects(ViewingRecord.self)
                .filter("viewingDate >= %@ AND viewingDate <= %@", startDate, endDate)
            
            let calendar = Calendar.current
            var weekdayCounts: [Int: Int] = [:]
            
            for record in records {
                let weekday = calendar.component(.weekday, from: record.viewingDate)
                // weekday: 1(일요일) ~ 7(토요일)을 1(월요일) ~ 7(일요일)로 변환
                let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
                weekdayCounts[adjustedWeekday, default: 0] += 1
            }
            
            let weekdayNames = ["월", "화", "수", "목", "금", "토", "일"]
            return (1...7).map { index in
                WeekdayStats(
                    weekday: weekdayNames[index - 1],
                    weekdayIndex: index,
                    count: weekdayCounts[index, default: 0]
                )
            }
        } catch {
            Logger.data.error("요일별 통계 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getWeeklyStats(from startDate: Date, to endDate: Date) -> [WeeklyStats] {
        do {
            let realm = try realmManager.getRealm()
            let records = realm.objects(ViewingRecord.self)
                .filter("viewingDate >= %@ AND viewingDate <= %@", startDate, endDate)
            
            let calendar = Calendar.current
            var weeklyCounts: [Int: Int] = [:]
            
            for record in records {
                // 해당 월의 몇 주차인지 계산
                let weekOfMonth = calendar.component(.weekOfMonth, from: record.viewingDate)
                weeklyCounts[weekOfMonth, default: 0] += 1
            }
            
            // 해당 월의 총 주차 수 계산
            let weekRange = calendar.range(of: .weekOfMonth, in: .month, for: startDate)
            let maxWeeks = weekRange?.count ?? 5
            
            return (1...maxWeeks).map { weekNumber in
                WeeklyStats(
                    weekNumber: weekNumber,
                    count: weeklyCounts[weekNumber, default: 0]
                )
            }
        } catch {
            Logger.data.error("주차별 통계 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getMonthlyStats(from startDate: Date, to endDate: Date) -> [MonthlyStats] {
        do {
            let realm = try realmManager.getRealm()
            let records = realm.objects(ViewingRecord.self)
                .filter("viewingDate >= %@ AND viewingDate <= %@", startDate, endDate)
            
            let calendar = Calendar.current
            var monthlyCounts: [Int: Int] = [:]
            
            for record in records {
                let month = calendar.component(.month, from: record.viewingDate)
                monthlyCounts[month, default: 0] += 1
            }
            
            return (1...12).map { month in
                MonthlyStats(
                    month: month,
                    count: monthlyCounts[month, default: 0]
                )
            }
        } catch {
            Logger.data.error("월별 통계 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getGenreStats(from startDate: Date, to endDate: Date) -> [GenreStats] {
        do {
            let realm = try realmManager.getRealm()
            let records = realm.objects(ViewingRecord.self)
                .filter("viewingDate >= %@ AND viewingDate <= %@", startDate, endDate)
            
            var genreCounts: [String: Int] = [:]
            
            for record in records {
                let displayName = convertGenreToDisplayName(record.genre)
                genreCounts[displayName, default: 0] += 1
            }
            
            let totalCount = records.count
            return genreCounts
                .filter { $0.value > 0 } // 1편 이상만
                .map { genre, count in
                    let percentage = totalCount > 0 ? (Double(count) / Double(totalCount)) * 100 : 0
                    return GenreStats(genre: genre, count: count, percentage: percentage)
                }
                .sorted { $0.count > $1.count }
        } catch {
            Logger.data.error("장르별 통계 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getCompanionStats(from startDate: Date, to endDate: Date) -> [CompanionStats] {
        do {
            let realm = try realmManager.getRealm()
            let records = realm.objects(ViewingRecord.self)
                .filter("viewingDate >= %@ AND viewingDate <= %@", startDate, endDate)
            
            var companionCounts: [String: Int] = [:]
            
            for record in records where !record.companion.isEmpty {
                companionCounts[record.companion, default: 0] += 1
            }
            
            // 혼자, 친구, 가족, 연인 순서로 정렬
            let order = ["혼자", "친구", "가족", "연인"]
            return order.compactMap { companion in
                guard let count = companionCounts[companion], count > 0 else { return nil }
                return CompanionStats(companion: companion, count: count)
            }
        } catch {
            Logger.data.error("동행인별 통계 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getAreaStats(from startDate: Date, to endDate: Date) -> [AreaStats] {
        do {
            let realm = try realmManager.getRealm()
            let records = realm.objects(ViewingRecord.self)
                .filter("viewingDate >= %@ AND viewingDate <= %@", startDate, endDate)
            
            var area: [String: Int] = [:]
            
            for record in records where !record.area.isEmpty {
                area[record.area, default: 0] += 1
            }
            
            return area
                .filter { $0.value > 0 } // 1편 이상만
                .map { area, count in
                    AreaStats(area: area, count: count)
                }
                .sorted { $0.count > $1.count }
        } catch {
            Logger.data.error("지역별 통계 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getMostFrequentWeekday(from startDate: Date, to endDate: Date) -> String? {
        let weekdayStats = getWeekdayStats(from: startDate, to: endDate)
        let maxStat = weekdayStats.max(by: { $0.count < $1.count })
        
        return maxStat?.count ?? 0 > 0 ? maxStat?.weekday : nil
    }
    
    func getMostFrequentGenre(from startDate: Date, to endDate: Date) -> String? {
        let genreStats = getGenreStats(from: startDate, to: endDate)
        return genreStats.first?.genre
    }
    
    func getMostFrequentMonth(from startDate: Date, to endDate: Date) -> String? {
        let monthlyStats = getMonthlyStats(from: startDate, to: endDate)
        let maxStat = monthlyStats.max(by: { $0.count < $1.count })
        
        return maxStat?.count ?? 0 > 0 ? maxStat?.displayName : nil
    }
    
    // MARK: - Private Helper
    
    // Genre 값을 DisplayName으로 변환
    // - Code면 DisplayName으로, 이미 DisplayName이면 그대로 반환
    private func convertGenreToDisplayName(_ genreValue: String) -> String {
        guard !genreValue.isEmpty else { return "기타" }
        
        // 1. Code로 간주하고 변환 시도
        if let genreCode = GenreCode(rawValue: genreValue) {
            return genreCode.displayName
        }
        
        // 2. 이미 DisplayName인 경우 (마이그레이션 전 데이터 대비)
        if GenreCode.allCases.contains(where: { $0.displayName == genreValue }) {
            return genreValue
        }
        
        // 3. 알 수 없는 값
        return "기타"
    }
}


// MARK: - Statistics Model
struct ViewingStatistics {
    let totalCount: Int
    let averageRating: Double
    let genreCount: [String: Int]
    
    // 가장 많이 본 장르
    var mostViewedGenre: String? {
        return genreCount.max(by: { $0.value < $1.value })?.key
    }
    
    // 장르별 통계를 정렬된 배열로 반환
    var sortedGenreCount: [(genre: String, count: Int)] {
        return genreCount.sorted { $0.value > $1.value }
            .map { (genre: $0.key, count: $0.value) }
    }
    
    // 평균 별점 (소수점 1자리)
    var formattedAverageRating: String {
        return String(format: "%.1f", averageRating)
    }
}

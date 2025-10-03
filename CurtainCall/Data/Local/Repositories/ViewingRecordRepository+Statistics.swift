//
//  ViewingRecordRepository+Statistics.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation
import RealmSwift
import OSLog

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
                let genre: String
                if let genreCode = GenreCode(rawValue: record.genre) {
                    genre = genreCode.displayName
                } else {
                    genre = "기타"
                }
                genreCounts[genre, default: 0] += 1
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
    
    func getLocationStats(from startDate: Date, to endDate: Date) -> [AreaStats] {
        do {
            let realm = try realmManager.getRealm()
            let records = realm.objects(ViewingRecord.self)
                .filter("viewingDate >= %@ AND viewingDate <= %@", startDate, endDate)
            
            var locationCounts: [String: Int] = [:]
            
            for record in records where !record.area.isEmpty {
                locationCounts[record.area, default: 0] += 1
            }
            
            return locationCounts
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
        return weekdayStats.max(by: { $0.count < $1.count })?.weekday
    }
    
    func getMostFrequentGenre(from startDate: Date, to endDate: Date) -> String? {
        let genreStats = getGenreStats(from: startDate, to: endDate)
        return genreStats.first?.genre
    }
    
    func getMostFrequentMonth(from startDate: Date, to endDate: Date) -> String? {
        let monthlyStats = getMonthlyStats(from: startDate, to: endDate)
        return monthlyStats.max(by: { $0.count < $1.count })?.displayName
    }
}

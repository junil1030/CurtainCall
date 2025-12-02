//
//  MockViewingRecordRepository.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import Foundation
import RealmSwift
@testable import CurtainCall

final class MockViewingRecordRepository: ViewingRecordRepositoryProtocol {

    // MARK: - Mock Data Storage
    private var records: [String: ViewingRecord] = [:]

    // MARK: - Mock Error Control
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: -1, userInfo: nil)

    // MARK: - Create
    func addRecord(_ record: ViewingRecord) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        records[record.id.stringValue] = record
    }

    // MARK: - Read
    func getRecords() -> [ViewingRecord] {
        return Array(records.values)
            .sorted { $0.viewingDate > $1.viewingDate }
    }

    func getRecordsByDate(from startDate: Date, to endDate: Date) -> [ViewingRecord] {
        return records.values
            .filter { $0.viewingDate >= startDate && $0.viewingDate <= endDate }
            .sorted { $0.viewingDate > $1.viewingDate }
    }

    func getRecordsByPerformance(performanceId: String) -> [ViewingRecord] {
        return records.values
            .filter { $0.performanceId == performanceId }
            .sorted { $0.viewingDate > $1.viewingDate }
    }

    func getRecordCount() -> Int {
        return records.count
    }

    func getRecord(by id: String) -> ViewingRecord? {
        guard let objectId = try? ObjectId(string: id) else {
            return nil
        }
        return records[objectId.stringValue]
    }

    // MARK: - Update
    func updateRecord(_ record: ViewingRecord) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        records[record.id.stringValue] = record
    }

    func updateRating(id: String, rating: Int) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        guard let record = getRecord(by: id) else {
            throw UpdateViewingRecordError.recordNotFound
        }
        record.rating = rating
        record.updatedAt = Date()
    }

    func updateMemo(id: String, memo: String) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        guard let record = getRecord(by: id) else {
            throw UpdateViewingRecordError.recordNotFound
        }
        record.memo = memo
        record.updatedAt = Date()
    }

    func updateRecordFields(id: String, viewingDate: Date, companion: String, seat: String, rating: Int, memo: String) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        guard let record = getRecord(by: id) else {
            throw UpdateViewingRecordError.recordNotFound
        }
        record.viewingDate = viewingDate
        record.companion = companion
        record.seat = seat
        record.rating = rating
        record.memo = memo
        record.updatedAt = Date()
    }

    // MARK: - Delete
    func deleteRecord(id: String) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        guard let objectId = try? ObjectId(string: id) else {
            return
        }
        records.removeValue(forKey: objectId.stringValue)
    }

    func deleteAllRecords() throws {
        if shouldThrowError {
            throw errorToThrow
        }
        records.removeAll()
    }

    // MARK: - Statistics (Stub implementations)
    func getStatistics() -> ViewingStatistics {
        return ViewingStatistics(
            totalCount: records.count,
            genreCount: [:],
            monthlyCount: [:],
            averageRating: 0.0
        )
    }

    func getStatsByPeriod(from startDate: Date, to endDate: Date) -> PeriodStatistics {
        return PeriodStatistics(totalCount: 0, totalHours: 0.0, averageRating: 0.0, favoriteGenre: nil)
    }

    func getWeekdayStats(from startDate: Date, to endDate: Date) -> [WeekdayStats] {
        return []
    }

    func getWeeklyStats(from startDate: Date, to endDate: Date) -> [WeeklyStats] {
        return []
    }

    func getMonthlyStats(from startDate: Date, to endDate: Date) -> [MonthlyStats] {
        return []
    }

    func getGenreStats(from startDate: Date, to endDate: Date) -> [GenreStats] {
        return []
    }

    func getCompanionStats(from startDate: Date, to endDate: Date) -> [CompanionStats] {
        return []
    }

    func getAreaStats(from startDate: Date, to endDate: Date) -> [AreaStats] {
        return []
    }

    func getMostFrequentWeekday(from startDate: Date, to endDate: Date) -> String? {
        return nil
    }

    func getMostFrequentGenre(from startDate: Date, to endDate: Date) -> String? {
        return nil
    }

    func getMostFrequentMonth(from startDate: Date, to endDate: Date) -> String? {
        return nil
    }

    // MARK: - Test Helpers
    func reset() {
        records.removeAll()
        shouldThrowError = false
    }

    func addRecordDirect(_ record: ViewingRecord) {
        records[record.id.stringValue] = record
    }
}

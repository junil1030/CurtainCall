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
    
    func getRecord(by id: ObjectId) -> ViewingRecord? {
        do {
            let realm = try realmManager.getRealm()
            return realm.object(ofType: ViewingRecord.self, forPrimaryKey: id)
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
    
    func updateRating(id: ObjectId, rating: Int) throws {
        guard rating >= 0 && rating <= 5 else {
            throw NSError(domain: "ViewingRecordRepository", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "별점은 0~5 사이여야 합니다."
            ])
        }
        
        do {
            try realmManager.write { realm in
                guard let record = realm.object(ofType: ViewingRecord.self, forPrimaryKey: id) else {
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
    
    func updateMemo(id: ObjectId, memo: String) throws {
        do {
            try realmManager.write { realm in
                guard let record = realm.object(ofType: ViewingRecord.self, forPrimaryKey: id) else {
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
    
    // MARK: - Delete
    func deleteRecord(id: ObjectId) throws {
        do {
            try realmManager.write { realm in
                guard let record = realm.object(ofType: ViewingRecord.self, forPrimaryKey: id) else {
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
                // GenreCode의 displayName을 키로 사용
                if let genreCode = GenreCode(rawValue: record.genre) {
                    genreCount[genreCode.displayName, default: 0] += 1
                } else {
                    // GenreCode에 없는 경우 "기타"로 분류
                    genreCount["기타", default: 0] += 1
                }
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

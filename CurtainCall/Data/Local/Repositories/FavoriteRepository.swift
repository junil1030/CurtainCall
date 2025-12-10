//
//  FavoriteRepository.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import Foundation
import RealmSwift
import OSLog

final class FavoriteRepository: FavoriteRepositoryProtocol {
    
    // MARK: - Properties
    private let realmProvider: RealmProvider
    
    // MARK: - Init
    init(realmProvider: RealmProvider) {
        self.realmProvider = realmProvider
    }
    
    // MARK: - Read
    func getFavorites() -> [FavoriteDTO] {
        do {
            let realm = try realmProvider.realm()
            let favorites = realm.objects(FavoritePerformance.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
            
            return FavoriteRealmMapper.toDTOs(from: Array(favorites))
        } catch {
            Logger.data.error("찜 목록 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getFavoritesByGenre(_ genre: String) -> [FavoriteDTO] {
        do {
            let realm = try realmProvider.realm()
            let favorites = realm.objects(FavoritePerformance.self)
                .filter("genre == %@", genre)
                .sorted(byKeyPath: "createdAt", ascending: false)
            
            return FavoriteRealmMapper.toDTOs(from: Array(favorites))
        } catch {
            Logger.data.error("장르별 찜 목록 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getFavoritesByArea(_ area: String) -> [FavoriteDTO] {
        do {
            let realm = try realmProvider.realm()
            let favorites = realm.objects(FavoritePerformance.self)
                .filter("area == %@", area)
                .sorted(byKeyPath: "createdAt", ascending: false)
            
            return FavoriteRealmMapper.toDTOs(from: Array(favorites))
        } catch {
            Logger.data.error("지역별 찜 목록 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getFavorite(id: String) -> FavoriteDTO? {
        do {
            let realm = try realmProvider.realm()
            guard let favorite = realm.object(ofType: FavoritePerformance.self, forPrimaryKey: id) else {
                return nil
            }
            return FavoriteRealmMapper.toDTO(from: favorite)
        } catch {
            Logger.data.error("찜 단건 조회 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    func isFavorite(id: String) -> Bool {
        return getFavorite(id: id) != nil
    }
    
    func getFavoriteCount() -> Int {
        do {
            let realm = try realmProvider.realm()
            return realm.objects(FavoritePerformance.self).count
        } catch {
            Logger.data.error("찜 개수 조회 실패: \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - Toggle (Primary Method)
    func toggleFavorite(_ dto: FavoriteDTO) throws -> Bool {
        let realm = try realmProvider.realm()

        let result: Bool
        if let existing = realm.object(ofType: FavoritePerformance.self, forPrimaryKey: dto.id) {
            // 이미 존재하면 삭제
            try realm.write {
                realm.delete(existing)
            }
            Logger.data.info("찜 삭제: \(dto.title)")
            result = false
        } else {
            // 존재하지 않으면 추가
            let favorite = FavoriteRealmMapper.toRealmModel(from: dto)
            try realm.write {
                realm.add(favorite, update: .modified)
            }
            Logger.data.info("찜 추가: \(dto.title)")
            result = true
        }

        // Widget 데이터 업데이트
        WidgetDataManager.shared.updateWidgetData()

        // Live Activity 업데이트 (iOS 16.2+)
        if #available(iOS 16.2, *) {
            LiveActivityManager.shared.refreshLiveActivityFromRealm()
        }

        return result
    }
    
    // MARK: - Delete
    func removeFavorite(id: String) throws {
        let realm = try realmProvider.realm()
        
        guard let favorite = realm.object(ofType: FavoritePerformance.self, forPrimaryKey: id) else {
            Logger.data.warning("삭제할 찜을 찾을 수 없음: \(id)")
            return
        }
        
        try realm.write {
            realm.delete(favorite)
        }
        
        Logger.data.info("찜 삭제 성공: \(id)")

        // Widget 데이터 업데이트
        WidgetDataManager.shared.updateWidgetData()

        // Live Activity 업데이트 (iOS 16.2+)
        if #available(iOS 16.2, *) {
            LiveActivityManager.shared.refreshLiveActivityFromRealm()
        }
    }
    
    func clearAllFavorites() throws {
        let realm = try realmProvider.realm()
        let favorites = realm.objects(FavoritePerformance.self)
        
        try realm.write {
            realm.delete(favorites)
        }
        
        Logger.data.info("찜 전체 삭제 완료")
    }
    
    // MARK: - Search
    func searchFavorites(keyword: String) -> [FavoriteDTO] {
        do {
            let realm = try realmProvider.realm()
            let favorites = realm.objects(FavoritePerformance.self)
                .filter("title CONTAINS[c] %@", keyword)
                .sorted(byKeyPath: "createdAt", ascending: false)
            
            return FavoriteRealmMapper.toDTOs(from: Array(favorites))
        } catch {
            Logger.data.error("찜 검색 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Statistics
    func getFavoriteStatistics() -> FavoriteStatistics {
        do {
            let realm = try realmProvider.realm()
            let favorites = realm.objects(FavoritePerformance.self)
            
            let totalCount = favorites.count
            
            // 장르별 통계 - GenreCode 사용
            var genreCount: [String: Int] = [:]
            for favorite in favorites {
                let genreValue = favorite.genre
                if let genreCode = GenreCode(rawValue: genreValue) {
                    genreCount[genreCode.displayName, default: 0] += 1
                } else {
                    genreCount["기타", default: 0] += 1
                }
            }
            
            // 지역별 통계 - AreaCode 사용
            var areaCount: [String: Int] = [:]
            for favorite in favorites {
                let areaValue = favorite.area
                if let areaCode = AreaCode(rawValue: areaValue) {
                    areaCount[areaCode.displayName, default: 0] += 1
                } else {
                    areaCount["기타", default: 0] += 1
                }
            }
            
            return FavoriteStatistics(
                totalCount: totalCount,
                genreCount: genreCount,
                areaCount: areaCount
            )
        } catch {
            Logger.data.error("찜 통계 조회 실패: \(error.localizedDescription)")
            return FavoriteStatistics(totalCount: 0, genreCount: [:], areaCount: [:])
        }
    }
    
    func getMonthlyFavoriteCount() -> Int {
        do {
            let realm = try realmProvider.realm()
            
            // 이번 달 시작일과 종료일 계산
            let calendar = Calendar.current
            let now = Date()
            
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
                  let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
                Logger.data.error("이번 달 날짜 계산 실패")
                return 0
            }
            
            // 이번 달에 추가된 찜 조회
            let monthlyFavorites = realm.objects(FavoritePerformance.self)
                .filter("createdAt >= %@ AND createdAt <= %@", startOfMonth, endOfMonth)
            
            return monthlyFavorites.count
        } catch {
            Logger.data.error("이번 달 찜 개수 조회 실패: \(error.localizedDescription)")
            return 0
        }
    }
}

// MARK: - Statistics Model
struct FavoriteStatistics {
    let totalCount: Int
    let genreCount: [String: Int]
    let areaCount: [String: Int]
    
    var mostFavoriteGenre: String? {
        return genreCount.max(by: { $0.value < $1.value })?.key
    }
    
    var mostFavoriteArea: String? {
        return areaCount.max(by: { $0.value < $1.value })?.key
    }
    
    // 장르별 통계를 정렬된 배열로 반환
    var sortedGenreCount: [(genre: String, count: Int)] {
        return genreCount.sorted { $0.value > $1.value }
            .map { (genre: $0.key, count: $0.value) }
    }
    
    // 지역별 통계를 정렬된 배열로 반환
    var sortedAreaCount: [(area: String, count: Int)] {
        return areaCount.sorted { $0.value > $1.value }
            .map { (area: $0.key, count: $0.value) }
    }
}

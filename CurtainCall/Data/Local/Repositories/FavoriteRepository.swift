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
    private let realmManager = RealmManager.shared
    
    // MARK: - Read
    func getFavorites() -> [FavoriteDTO] {
        do {
            let realm = try realmManager.getRealm()
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
            let realm = try realmManager.getRealm()
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
            let realm = try realmManager.getRealm()
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
            let realm = try realmManager.getRealm()
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
            let realm = try realmManager.getRealm()
            return realm.objects(FavoritePerformance.self).count
        } catch {
            Logger.data.error("찜 개수 조회 실패: \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - Toggle (Primary Method)
    func toggleFavorite(_ dto: FavoriteDTO) throws -> Bool {
        let performanceId = dto.id
        
        do {
            if let existingFavorite = try getRealmFavorite(id: performanceId) {
                // 이미 찜한 경우 -> 삭제
                try realmManager.write { realm in
                    realm.delete(existingFavorite)
                    Logger.data.info("찜 삭제 성공: \(dto.title)")
                }
                return false
            } else {
                // 찜하지 않은 경우 -> 추가
                let favorite = FavoriteRealmMapper.toRealmModel(from: dto)
                try realmManager.write { realm in
                    realm.add(favorite)
                    Logger.data.info("찜 추가 성공: \(dto.title)")
                }
                return true
            }
        } catch {
            Logger.data.error("찜 토글 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Delete
    func removeFavorite(id: String) throws {
        do {
            try realmManager.write { realm in
                guard let favorite = realm.object(ofType: FavoritePerformance.self, forPrimaryKey: id) else {
                    throw NSError(domain: "FavoriteRepository", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "해당 ID의 찜을 찾을 수 없습니다."
                    ])
                }
                
                let title = favorite.title
                realm.delete(favorite)
                Logger.data.info("찜 삭제 성공: \(title)")
            }
        } catch {
            Logger.data.error("찜 삭제 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    func clearAllFavorites() throws {
        do {
            try realmManager.write { realm in
                let favorites = realm.objects(FavoritePerformance.self)
                realm.delete(favorites)
                Logger.data.info("모든 찜 삭제 성공")
            }
        } catch {
            Logger.data.error("모든 찜 삭제 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Search
    func searchFavorites(keyword: String) -> [FavoriteDTO] {
        do {
            let realm = try realmManager.getRealm()
            let favorites = realm.objects(FavoritePerformance.self)
                .filter("title CONTAINS[c] %@ OR location CONTAINS[c] %@", keyword, keyword)
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
            let realm = try realmManager.getRealm()
            let favorites = realm.objects(FavoritePerformance.self)
            
            let totalCount = favorites.count
            
            // 장르별 통계 - GenreCode 사용
            var genreCount: [String: Int] = [:]
            for favorite in favorites {
                if let genreCode = GenreCode(rawValue: favorite.genre) {
                    genreCount[genreCode.displayName, default: 0] += 1
                } else {
                    genreCount["기타", default: 0] += 1
                }
            }
            
            // 지역별 통계 - AreaCode 사용
            var areaCount: [String: Int] = [:]
            for favorite in favorites {
                if let areaCode = AreaCode(rawValue: favorite.area) {
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
    
    // MARK: - Private Helpers
    
    /// Realm 모델을 직접 조회 (내부 사용)
    private func getRealmFavorite(id: String) throws -> FavoritePerformance? {
        let realm = try realmManager.getRealm()
        return realm.object(ofType: FavoritePerformance.self, forPrimaryKey: id)
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

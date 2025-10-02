//
//  RecentSearchRepository.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import Foundation
import RealmSwift
import OSLog

final class RecentSearchRepository: RecentSearchRepositoryProtocol {
    
    // MARK: - Properties
    private let realmManager = RealmManager.shared
    private let maxSearchCount = 10  // 최대 저장 개수
    
    // MARK: - Create
    func addSearch(_ keyword: String) throws {
        // 빈 검색어 체크
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKeyword.isEmpty else {
            Logger.data.warning("빈 검색어는 저장하지 않습니다.")
            return
        }
        
        do {
            try realmManager.write { realm in
                // 1. 기존에 같은 검색어가 있으면 삭제
                let existingSearches = realm.objects(RecentSearchKeyword.self)
                    .filter("keyword == %@", trimmedKeyword)
                realm.delete(existingSearches)
                
                // 2. 새로운 검색어 추가
                let newSearch = RecentSearchKeyword(keyword: trimmedKeyword)
                realm.add(newSearch)
                
                // 3. 최대 개수 초과시 가장 오래된 것 삭제
                let allSearches = realm.objects(RecentSearchKeyword.self)
                    .sorted(byKeyPath: "createdAt", ascending: false)
                
                if allSearches.count > maxSearchCount {
                    let excessCount = allSearches.count - maxSearchCount
                    let itemsToDelete = Array(allSearches.suffix(excessCount))
                    realm.delete(itemsToDelete)
                    
                    Logger.data.info("오래된 검색어 \(excessCount)개 삭제")
                }
                
                Logger.data.info("최근 검색어 추가 성공: \(trimmedKeyword)")
            }
        } catch {
            Logger.data.error("최근 검색어 추가 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Read
    func getRecentSearches(limit: Int = 10) -> [RecentSearch] {
        do {
            let realm = try realmManager.getRealm()
            let searches = realm.objects(RecentSearchKeyword.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
                .prefix(limit)
            
            // Realm Object를 일반 Struct로 변환
            return searches.map { realmObject in
                RecentSearch(
                    id: UUID(),
                    keyword: realmObject.keyword,
                    createdAt: realmObject.createdAt
                )
            }
        } catch {
            Logger.data.error("최근 검색어 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func searchKeyword(_ keyword: String) -> [RecentSearch] {
        do {
            let realm = try realmManager.getRealm()
            let searches = realm.objects(RecentSearchKeyword.self)
                .filter("keyword CONTAINS[c] %@", keyword)
                .sorted(byKeyPath: "createdAt", ascending: false)
            
            return searches.map { realmObject in
                RecentSearch(
                    id: UUID(),
                    keyword: realmObject.keyword,
                    createdAt: realmObject.createdAt
                )
            }
        } catch {
            Logger.data.error("검색어 검색 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getSearchCount() -> Int {
        do {
            let realm = try realmManager.getRealm()
            return realm.objects(RecentSearchKeyword.self).count
        } catch {
            Logger.data.error("검색어 개수 조회 실패: \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - Delete
    func deleteSearch(id: ObjectId) throws {
        do {
            try realmManager.write { realm in
                guard let search = realm.object(ofType: RecentSearchKeyword.self, forPrimaryKey: id) else {
                    throw NSError(domain: "RecentSearchRepository", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "해당 ID의 검색어를 찾을 수 없습니다."
                    ])
                }
                
                let keyword = search.keyword
                realm.delete(search)
                Logger.data.info("최근 검색어 삭제 성공: \(keyword)")
            }
        } catch {
            Logger.data.error("최근 검색어 삭제 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteSearchByKeyword(_ keyword: String) throws {
        do {
            try realmManager.write { realm in
                let searches = realm.objects(RecentSearchKeyword.self)
                    .filter("keyword == %@", keyword)
                
                guard !searches.isEmpty else {
                    throw NSError(domain: "RecentSearchRepository", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "해당 검색어를 찾을 수 없습니다."
                    ])
                }
                
                realm.delete(searches)
                Logger.data.info("검색어 삭제 성공: \(keyword)")
            }
        } catch {
            Logger.data.error("검색어 삭제 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    func clearAllSearches() throws {
        do {
            try realmManager.write { realm in
                let searches = realm.objects(RecentSearchKeyword.self)
                realm.delete(searches)
                Logger.data.info("모든 최근 검색어 삭제 성공")
            }
        } catch {
            Logger.data.error("모든 최근 검색어 삭제 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Utility
    func clearOldSearches(olderThan days: Int) throws {
        do {
            try realmManager.write { realm in
                let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
                let oldSearches = realm.objects(RecentSearchKeyword.self)
                    .filter("createdAt < %@", cutoffDate)
                
                let count = oldSearches.count
                realm.delete(oldSearches)
                
                Logger.data.info("\(days)일 이전 검색어 \(count)개 삭제 성공")
            }
        } catch {
            Logger.data.error("오래된 검색어 삭제 실패: \(error.localizedDescription)")
            throw error
        }
    }
}

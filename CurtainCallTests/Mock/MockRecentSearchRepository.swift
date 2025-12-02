//
//  MockRecentSearchRepository.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import Foundation
import RealmSwift
@testable import CurtainCall

final class MockRecentSearchRepository: RecentSearchRepositoryProtocol {

    // MARK: - Mock Data Storage
    private var searches: [UUID: RecentSearch] = [:]

    // MARK: - Mock Error Control
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: -1, userInfo: nil)

    // MARK: - Create
    func addSearch(_ keyword: String) throws {
        if shouldThrowError {
            throw errorToThrow
        }

        // 중복 키워드가 있으면 삭제하고 새로 추가 (최신으로 업데이트)
        if let existing = searches.values.first(where: { $0.keyword == keyword }) {
            searches.removeValue(forKey: existing.id)
        }

        let newSearch = RecentSearch(keyword: keyword, createdAt: Date())
        searches[newSearch.id] = newSearch
    }

    // MARK: - Read
    func getRecentSearches(limit: Int) -> [RecentSearch] {
        return Array(searches.values)
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }

    func searchKeyword(_ keyword: String) -> [RecentSearch] {
        return searches.values
            .filter { $0.keyword.contains(keyword) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func getSearchCount() -> Int {
        return searches.count
    }

    // MARK: - Delete
    func deleteSearch(id: ObjectId) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        // ObjectId는 사용하지 않으므로 구현하지 않음
    }

    func deleteSearchByKeyword(_ keyword: String) throws {
        if shouldThrowError {
            throw errorToThrow
        }

        if let search = searches.values.first(where: { $0.keyword == keyword }) {
            searches.removeValue(forKey: search.id)
        }
    }

    func clearAllSearches() throws {
        if shouldThrowError {
            throw errorToThrow
        }
        searches.removeAll()
    }

    // MARK: - Utility
    func clearOldSearches(olderThan days: Int) throws {
        if shouldThrowError {
            throw errorToThrow
        }

        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return
        }

        let oldSearchIds = searches.filter { $0.value.createdAt < cutoffDate }.map { $0.key }
        oldSearchIds.forEach { searches.removeValue(forKey: $0) }
    }

    // MARK: - Test Helpers
    func reset() {
        searches.removeAll()
        shouldThrowError = false
    }

    func addSearchDirect(_ search: RecentSearch) {
        searches[search.id] = search
    }
}

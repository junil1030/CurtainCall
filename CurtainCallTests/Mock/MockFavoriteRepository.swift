//
//  MockFavoriteRepository.swift
//  CurtainCallTests
//
//  Created by Claude Code
//

import Foundation
@testable import CurtainCall

final class MockFavoriteRepository: FavoriteRepositoryProtocol {

    // MARK: - Mock Data Storage
    private var favorites: [String: FavoriteDTO] = [:]

    // MARK: - Mock Error Control
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: -1, userInfo: nil)

    // MARK: - Read
    func getFavorites() -> [FavoriteDTO] {
        return Array(favorites.values)
            .sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
    }

    func getFavoritesByGenre(_ genre: String) -> [FavoriteDTO] {
        return favorites.values
            .filter { $0.genre == genre }
            .sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
    }

    func getFavoritesByArea(_ area: String) -> [FavoriteDTO] {
        return favorites.values
            .filter { $0.area == area }
            .sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
    }

    func getFavorite(id: String) -> FavoriteDTO? {
        return favorites[id]
    }

    func isFavorite(id: String) -> Bool {
        return favorites[id] != nil
    }

    func getFavoriteCount() -> Int {
        return favorites.count
    }

    func getMonthlyFavoriteCount() -> Int {
        let calendar = Calendar.current
        let now = Date()

        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return 0
        }

        return favorites.values.filter { favorite in
            guard let createdAt = favorite.createdAt else { return false }
            return createdAt >= startOfMonth && createdAt <= endOfMonth
        }.count
    }

    // MARK: - Toggle
    func toggleFavorite(_ dto: FavoriteDTO) throws -> Bool {
        if shouldThrowError {
            throw errorToThrow
        }

        if favorites[dto.id] != nil {
            favorites.removeValue(forKey: dto.id)
            return false
        } else {
            favorites[dto.id] = dto
            return true
        }
    }

    // MARK: - Delete
    func removeFavorite(id: String) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        favorites.removeValue(forKey: id)
    }

    func clearAllFavorites() throws {
        if shouldThrowError {
            throw errorToThrow
        }
        favorites.removeAll()
    }

    // MARK: - Search
    func searchFavorites(keyword: String) -> [FavoriteDTO] {
        return favorites.values
            .filter { $0.title.lowercased().contains(keyword.lowercased()) }
            .sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
    }

    // MARK: - Statistics
    func getFavoriteStatistics() -> FavoriteStatistics {
        let totalCount = favorites.count

        var genreCount: [String: Int] = [:]
        for favorite in favorites.values {
            guard let genre = favorite.genre else { continue }
            if let genreCode = GenreCode(rawValue: genre) {
                genreCount[genreCode.displayName, default: 0] += 1
            } else {
                genreCount["기타", default: 0] += 1
            }
        }

        var areaCount: [String: Int] = [:]
        for favorite in favorites.values {
            guard let area = favorite.area else { continue }
            if let areaCode = AreaCode(rawValue: area) {
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
    }

    // MARK: - Test Helpers
    func reset() {
        favorites.removeAll()
        shouldThrowError = false
    }

    func addFavorite(_ dto: FavoriteDTO) {
        favorites[dto.id] = dto
    }
}

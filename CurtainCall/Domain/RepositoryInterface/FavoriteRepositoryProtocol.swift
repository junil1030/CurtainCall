//
//  FavoriteRepositoryProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation

protocol FavoriteRepositoryProtocol {
    // Read
    func getFavorites() -> [FavoritePerformance]
    func getFavoritesByGenre(_ genre: String) -> [FavoritePerformance]
    func getFavoritesByArea(_ area: String) -> [FavoritePerformance]
    func getFavorite(id: String) -> FavoritePerformance?
    func isFavorite(id: String) -> Bool
    func getFavoriteCount() -> Int
    
    // Toggle
    func toggleFavorite(_ performance: PerformanceDetail) throws -> Bool
    
    // Delete
    func removeFavorite(id: String) throws
    func clearAllFavorites() throws
    
    // Search
    func searchFavorites(keyword: String) -> [FavoritePerformance]
    
    // Statistics
    func getFavoriteStatistics() -> FavoriteStatistics
}

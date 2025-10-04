//
//  FavoriteRepositoryProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation

protocol FavoriteRepositoryProtocol {
    // Read
    func getFavorites() -> [FavoriteDTO]
    func getFavoritesByGenre(_ genre: String) -> [FavoriteDTO]
    func getFavoritesByArea(_ area: String) -> [FavoriteDTO]
    func getFavorite(id: String) -> FavoriteDTO?
    func isFavorite(id: String) -> Bool
    func getFavoriteCount() -> Int
    func getMonthlyFavoriteCount() -> Int
    
    // Toggle
    func toggleFavorite(_ dto: FavoriteDTO) throws -> Bool
    
    // Delete
    func removeFavorite(id: String) throws
    func clearAllFavorites() throws
    
    // Search
    func searchFavorites(keyword: String) -> [FavoriteDTO]
    
    // Statistics
    func getFavoriteStatistics() -> FavoriteStatistics
}

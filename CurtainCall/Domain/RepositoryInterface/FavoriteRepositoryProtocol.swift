//
//  FavoriteRepositoryProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation

protocol FavoriteRepositoryProtocol {
    func addFavorite(_ performance: FavoritePerformance) throws
    func removeFavorite(id: String) throws
    func getFavorites() -> [FavoritePerformance]
    func isFavorite(id: String) -> Bool
    func getFavoriteCount() -> Int
}

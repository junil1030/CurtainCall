//
//  FetchFavoritesUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import Foundation

final class FetchFavoritesUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = FavoriteFilterCondition
    typealias Output = [FavoriteDTO]
    
    // MARK: - Properties
    private let repository: FavoriteRepositoryProtocol
    
    // MARK: - Init
    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: FavoriteFilterCondition) -> [FavoriteDTO] {
        var favorites: [FavoriteDTO]
        
        // 1. 장르 필터 적용
        if let genre = input.genre {
            favorites = repository.getFavoritesByGenre(genre.rawValue)
        } else {
            favorites = repository.getFavorites()
        }
        
        // 2. 지역 필터 적용
        if let area = input.area {
            favorites = favorites.filter { $0.area == area.rawValue }
        }
        
        // 3. 정렬 적용
        switch input.sortType {
        case .latest:
            favorites = favorites.sorted {
                ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast)
            }
            
        case .oldest:
            favorites = favorites.sorted {
                ($0.createdAt ?? Date.distantPast) < ($1.createdAt ?? Date.distantPast)
            }
            
        case .nameAscending:
            favorites = favorites.sorted { $0.title < $1.title }
            
        case .nameDescending:
            favorites = favorites.sorted { $0.title > $1.title }
        }
        
        return favorites
    }
}

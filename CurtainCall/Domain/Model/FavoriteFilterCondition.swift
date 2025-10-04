//
//  FavoriteFilterCondition.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import Foundation

struct FavoriteFilterCondition {
    let sortType: SortType
    let genre: GenreCode?
    let area: AreaCode?
    
    // MARK: - SortType
    enum SortType {
        case latest         // 최신순
        case oldest         // 오래된순
        case nameAscending  // 이름 오름차순
        case nameDescending // 이름 내림차순
    }
    
    // MARK: - Init
    init(
        sortType: SortType = .latest,
        genre: GenreCode? = nil,
        area: AreaCode? = nil
    ) {
        self.sortType = sortType
        self.genre = genre
        self.area = area
    }
    
    // MARK: - Default
    static let `default` = FavoriteFilterCondition()
}

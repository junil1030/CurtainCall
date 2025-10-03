//
//  SearchResultToFavoriteDTOMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

struct SearchResultToFavoriteDTOMapper {
    
    static func map(from searchResult: SearchResult) -> FavoriteDTO {
        return FavoriteDTO(
            id: searchResult.id,
            title: searchResult.title,
            posterURL: searchResult.posterURL,
            location: searchResult.location,
            startDate: searchResult.startDate,
            endDate: searchResult.endDate,
            area: searchResult.area,
            genre: searchResult.genre,
            createdAt: Date(),
            lastUpdated: Date()
        )
    }
}

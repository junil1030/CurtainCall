//
//  SearchResultToFavoriteDTOMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

struct SearchResultToFavoriteDTOMapper {
    
    static func map(from searchResult: SearchResult) -> FavoriteDTO {
        
        let genreRawValue = GenreCode.from(displayName: searchResult.genre)?.rawValue ?? searchResult.genre
        let areaRawValue = AreaCode.from(displayName: searchResult.area)?.rawValue ?? searchResult.area
        
        return FavoriteDTO(
            id: searchResult.id,
            title: searchResult.title,
            posterURL: searchResult.posterURL,
            location: searchResult.location,
            startDate: searchResult.startDate,
            endDate: searchResult.endDate,
            area: areaRawValue,
            genre: genreRawValue,
            createdAt: Date(),
            lastUpdated: Date()
        )
    }
}

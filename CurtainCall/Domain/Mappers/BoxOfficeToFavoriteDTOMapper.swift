//
//  BoxOfficeToFavoriteDTOMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

struct BoxOfficeToFavoriteDTOMapper {
    
    static func map(from boxOffice: BoxOffice) -> FavoriteDTO {
        
        let genreRawValue = GenreCode.from(displayName: boxOffice.genre)?.rawValue ?? boxOffice.genre
        let areaRawValue = AreaCode.from(displayName: boxOffice.area)?.rawValue ?? boxOffice.area
        
        return FavoriteDTO(
            id: boxOffice.performanceID,
            title: boxOffice.title,
            posterURL: boxOffice.posterURL,
            location: boxOffice.location,
            startDate: boxOffice.startDate,
            endDate: boxOffice.endDate,
            area: areaRawValue,
            genre: genreRawValue,
            createdAt: Date(),
            lastUpdated: Date()
        )
    }
}

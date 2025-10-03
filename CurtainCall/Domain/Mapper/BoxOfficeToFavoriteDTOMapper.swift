//
//  BoxOfficeToFavoriteDTOMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

struct BoxOfficeToFavoriteDTOMapper {
    
    static func map(from boxOffice: BoxOffice) -> FavoriteDTO {
        return FavoriteDTO(
            id: boxOffice.performanceID,
            title: boxOffice.title,
            posterURL: boxOffice.posterURL,
            location: boxOffice.location,
            startDate: boxOffice.startDate,
            endDate: boxOffice.endDate,
            area: boxOffice.area,
            genre: boxOffice.genre,
            createdAt: Date(),
            lastUpdated: Date()
        )
    }
}

//
//  PerformanceDetailToFavoriteDTOMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

struct PerformanceDetailToFavoriteDTOMapper {
    
    static func map(from detail: PerformanceDetail) -> FavoriteDTO {
        
        let genreRawValue = GenreCode.from(displayName: detail.genre ?? "")?.rawValue ?? detail.genre ?? "정보없음"
        let areaRawValue = AreaCode.from(displayName: detail.area ?? "")?.rawValue ?? detail.area ?? "정보없음"
        
        return FavoriteDTO(
            id: detail.id,
            title: detail.title,
            posterURL: detail.posterURL,
            location: detail.location ?? "정보없음",
            startDate: detail.startDate ?? "정보없음",
            endDate: detail.endDate ?? "정보없음",
            area: areaRawValue,
            genre: genreRawValue,
            createdAt: Date(),
            lastUpdated: Date()
        )
    }
}

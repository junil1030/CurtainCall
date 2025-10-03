//
//  PerformanceDetailToFavoriteDTOMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

struct PerformanceDetailToFavoriteDTOMapper {
    
    static func map(from detail: PerformanceDetail) -> FavoriteDTO {
        return FavoriteDTO(
            id: detail.id,
            title: detail.title,
            posterURL: detail.posterURL,
            location: detail.location ?? "정보없음",
            startDate: detail.startDate ?? "정보없음",
            endDate: detail.endDate ?? "정보없음",
            area: detail.area ?? "정보없음",
            genre: detail.genre ?? "정보없음",
            createdAt: Date(),
            lastUpdated: Date()
        )
    }
}

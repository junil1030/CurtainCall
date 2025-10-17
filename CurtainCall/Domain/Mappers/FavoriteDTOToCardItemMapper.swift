//
//  FavoriteDTOToCardItemMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import Foundation

struct FavoriteDTOToCardItemMapper {
    
    // FavoriteDTO를 CardItem으로 변환
    static func map(from dto: FavoriteDTO) -> CardItem {
        return CardItem(
            id: dto.id,
            imageURL: dto.safePosterURL,
            title: dto.title,
            subtitle: dto.safeLocation,
            period: "\(dto.safeStartDate)~\(dto.safeEndDate)",
            badge: "",  // 찜한 공연 목록에는 순위 정보 없음
        )
    }
    
    // FavoriteDTO 배열을 CardItem 배열로 변환
    static func map(from dtos: [FavoriteDTO]) -> [CardItem] {
        return dtos.map { map(from: $0) }
    }
}

//
//  FavoriteRealmMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

struct FavoriteRealmMapper {
    
    // MARK: - DTO → Realm Model
    static func toRealmModel(from dto: FavoriteDTO) -> FavoritePerformance {
        let realmModel = FavoritePerformance()
        realmModel.id = dto.id
        realmModel.title = dto.title
        realmModel.posterURL = dto.posterURL ?? ""
        realmModel.location = dto.location ?? ""
        realmModel.startDate = dto.startDate ?? ""
        realmModel.endDate = dto.endDate ?? ""
        realmModel.area = dto.area ?? ""
        realmModel.genre = dto.genre ?? ""
        realmModel.createdAt = dto.createdAt ?? Date()
        realmModel.lastUpdated = dto.lastUpdated ?? Date()
        
        return realmModel
    }
    
    // MARK: - Realm Model → DTO
    static func toDTO(from realmModel: FavoritePerformance) -> FavoriteDTO {
        return FavoriteDTO(
            id: realmModel.id,
            title: realmModel.title,
            posterURL: realmModel.posterURL,
            location: realmModel.location,
            startDate: realmModel.startDate,
            endDate: realmModel.endDate,
            area: realmModel.area,
            genre: realmModel.genre,
            createdAt: realmModel.createdAt,
            lastUpdated: realmModel.lastUpdated
        )
    }
    
    // MARK: - Realm Models → DTOs (Array)
    static func toDTOs(from realmModels: [FavoritePerformance]) -> [FavoriteDTO] {
        return realmModels.map { toDTO(from: $0) }
    }
}

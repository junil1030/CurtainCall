//
//  ViewingRecordRealmMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/10/25.
//

import Foundation

struct ViewingRecordRealmMapper {
    
    // ViewingRecord (Realm) → ViewingRecordDTO (Domain)
    static func toDomain(_ record: ViewingRecord) -> ViewingRecordDTO {
        return ViewingRecordDTO(
            id: record.id.stringValue,
            performanceId: record.performanceId,
            title: record.title,
            posterURL: record.posterURL,
            area: record.area,
            location: record.location,
            genre: record.genre,
            viewingDate: record.viewingDate,
            rating: record.rating,
            seat: record.seat,
            companion: record.companion,
            cast: record.cast,
            memo: record.memo,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt
        )
    }
    
    // ViewingRecordDTO (Domain) → ViewingRecord (Realm)
    static func toEntity(_ dto: ViewingRecordDTO) -> ViewingRecord {
        let record = ViewingRecord()
        record.performanceId = dto.performanceId
        record.title = dto.title
        record.posterURL = dto.posterURL ?? ""
        record.area = dto.area ?? ""
        record.location = dto.location ?? ""
        record.genre = dto.genre ?? ""
        record.viewingDate = dto.viewingDate
        record.rating = dto.rating
        record.seat = dto.seat
        record.companion = dto.companion
        record.cast = dto.cast
        record.memo = dto.memo
        record.createdAt = dto.createdAt
        record.updatedAt = dto.updatedAt
        return record
    }
    
    /// 배열 변환 헬퍼
    static func toDomainList(_ records: [ViewingRecord]) -> [ViewingRecordDTO] {
        return records.map { toDomain($0) }
    }
}

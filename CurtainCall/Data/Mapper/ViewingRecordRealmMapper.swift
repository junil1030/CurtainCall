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
            genre: convertCodeToDisplayName(record.genre),
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
        record.genre = convertToGenreCode(dto.genre ?? "")
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
    
    // MARK: - Private Helpers
    
    // Code를 DisplayName으로 변환 (조회용)
    private static func convertCodeToDisplayName(_ code: String) -> String {
        guard !code.isEmpty else { return "" }
        
        // 1. Code로 GenreCode 찾기
        if let genreCode = GenreCode(rawValue: code) {
            return genreCode.displayName
        }
        
        // 2. 이미 DisplayName인 경우 (마이그레이션 전 데이터)
        if GenreCode.allCases.contains(where: { $0.displayName == code }) {
            return code
        }
        
        // 3. 괄호 제거 후 매칭 시도 (혹시 남아있는 구버전 데이터)
        let cleanedCode = removeParenthesesContent(from: code)
        if GenreCode.allCases.contains(where: { $0.displayName == cleanedCode }) {
            return cleanedCode
        }
        
        // 4. 알 수 없는 값은 그대로 반환
        return code
    }
    
    // DisplayName 또는 Code를 받아서 Code로 변환
    private static func convertToGenreCode(_ value: String) -> String {
        guard !value.isEmpty else { return "" }
        
        // 1. 이미 Code 형식인지 확인
        if GenreCode(rawValue: value) != nil {
            return value  // 이미 Code면 그대로 반환
        }
        
        // 2. 괄호 제거한 버전으로 매칭 시도
        let cleanedValue = removeParenthesesContent(from: value)
        if let genreCode = GenreCode.from(displayName: cleanedValue) {
            return genreCode.rawValue
        }
        
        // 3. 원본으로도 한번 더 시도 (이미 괄호가 없는 경우)
        if let genreCode = GenreCode.from(displayName: value) {
            return genreCode.rawValue
        }
        
        // 4. 변환 실패 시 원본 반환
        return value
    }
    
    // 괄호와 괄호 안의 내용 제거
    private static func removeParenthesesContent(from text: String) -> String {
        return text.replacingOccurrences(of: "\\([^)]*\\)", with: "", options: .regularExpression)
    }
    
    // 배열 변환 헬퍼
    static func toDomainList(_ records: [ViewingRecord]) -> [ViewingRecordDTO] {
        return records.map { toDomain($0) }
    }
}

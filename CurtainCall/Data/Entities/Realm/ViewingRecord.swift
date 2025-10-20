//
//  ViewingRecord.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation
import RealmSwift

class ViewingRecord: Object {
    @Persisted(primaryKey: true) var id: ObjectId             // 자동 생성 ID
    @Persisted var performanceId: String                      // 공연 ID
    @Persisted var title: String                              // 공연명
    @Persisted var posterURL: String                          // 포스터 URL - 옵셔널
    @Persisted var area: String                               // 지역 - 옵셔널
    @Persisted var location: String                           // 공연장 - 옵셔널
    @Persisted var genre: String                              // 장르(Code로 저장) - 옵셔널
    @Persisted var viewingDate: Date                          // 관람한 날짜
    @Persisted var rating: Int = 0                            // 별점 (0~5, 0은 미평가)
    @Persisted var seat: String = ""                          // 좌석 정보
    @Persisted var companion: String = ""                     // 동행인 정보
    @Persisted var cast: String = ""                          // 관람한 출연진
    @Persisted var memo: String = ""                          // 감상평/메모
    @Persisted var imagePaths: List<String>                   // 이미지 파일 경로들 (나중에 구현)
    @Persisted var createdAt: Date                            // 기록 생성일
    @Persisted var updatedAt: Date                            // 기록 수정일
    
    // PerformanceDetail에서 생성하는 헬퍼
    convenience init(from detail: PerformanceDetail, viewingDate: Date) {
        self.init()
        self.performanceId = detail.id
        self.title = detail.title
        self.posterURL = detail.posterURL ?? ""
        self.area = detail.area ?? ""
        self.location = detail.location ?? ""
        self.genre = Self.convertToGenreCode(detail.genre ?? "")
        self.viewingDate = viewingDate
        self.imagePaths = List<String>()
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Private Helper
    
    // DisplayName 또는 Code를 받아서 Code로 변환
    private static func convertToGenreCode(_ value: String) -> String {
        guard !value.isEmpty else { return "" }
        
        // 1. 이미 Code 형식인지 확인
        if GenreCode(rawValue: value) != nil {
            return value
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
}

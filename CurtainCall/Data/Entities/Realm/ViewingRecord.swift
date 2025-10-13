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
    @Persisted var genre: String                              // 장르 - 옵셔널
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
        self.genre = detail.genre ?? ""
        self.viewingDate = viewingDate
        self.imagePaths = List<String>()
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

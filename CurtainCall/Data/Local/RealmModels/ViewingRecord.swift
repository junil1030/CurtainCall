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
    @Persisted var posterURL: String                          // 포스터 URL
    @Persisted var location: String                           // 공연장
    @Persisted var viewingDate: Date                          // 관람한 날짜
    @Persisted var rating: Int = 0                            // 별점 (0~5, 0은 미평가)
    @Persisted var seat: String = ""                          // 좌석 정보
    @Persisted var cast: String = ""                          // 관람한 출연진
    @Persisted var memo: String = ""                          // 감상평/메모
    @Persisted var createdAt: Date                            // 기록 생성일
    @Persisted var updatedAt: Date                            // 기록 수정일
    
    convenience init(
        performanceId: String,
        title: String,
        posterURL: String,
        location: String,
        viewingDate: Date
    ) {
        self.init()
        self.performanceId = performanceId
        self.title = title
        self.posterURL = posterURL
        self.location = location
        self.viewingDate = viewingDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

//
//  FavoritePerformance.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation
import RealmSwift

class FavoritePerformance: Object {
    @Persisted(primaryKey: true) var id: String               // 공연 ID (mt20id)
    @Persisted var title: String                              // 공연명
    @Persisted var posterURL: String                          // 포스터 URL (Kingfisher 캐싱)
    @Persisted var location: String                           // 공연장
    @Persisted var startDate: String                          // 시작일
    @Persisted var endDate: String                            // 종료일
    @Persisted var area: String                               // 지역
    @Persisted var genre: String                              // 장르
    @Persisted var createdAt: Date                            // 찜한 날짜
    @Persisted var lastUpdated: Date                          // 마지막 업데이트
    
    convenience init(from detail: PerformanceDetail) {
        self.init()
        self.id = detail.id
        self.title = detail.title
        self.posterURL = detail.posterURL
        self.location = detail.location ?? "정보없음"
        self.startDate = detail.startDate ?? "정보없음"
        self.endDate = detail.endDate ?? "정보없음"
        self.area = detail.area ?? "정보없음"
        self.genre = "장르정보"  // API에서 가져오기
        self.createdAt = Date()
        self.lastUpdated = Date()
    }
}

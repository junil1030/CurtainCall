//
//  PerformanceActivityAttributes.swift
//  CurtainCall
//
//  Created by 서준일 on 12/9/25.
//

import Foundation
import ActivityKit

/// Live Activity에 사용되는 Activity Attributes
/// Shared 폴더에 위치하여 메인 앱과 위젯 익스텐션 모두에서 접근 가능
@available(iOS 16.2, *)
public struct PerformanceActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // 동적으로 변하는 데이터
        public var dDay: Int // D-Day (양수: 시작 전, 음수: 진행 중, 0: 오늘 시작)
        public var remainingDays: Int // 공연 종료까지 남은 일수
        public var isStarted: Bool // 공연 시작 여부
        public var favoriteCount: Int // 전체 즐겨찾기 개수

        public init(dDay: Int, remainingDays: Int, isStarted: Bool, favoriteCount: Int) {
            self.dDay = dDay
            self.remainingDays = remainingDays
            self.isStarted = isStarted
            self.favoriteCount = favoriteCount
        }
    }

    // 고정 데이터 (Live Activity 생명주기 동안 변하지 않음)
    public var performanceId: String
    public var title: String
    public var facility: String
    public var startDate: String // "2025.12.16"
    public var endDate: String // "2026.03.30"
    public var genre: String

    public init(
        performanceId: String,
        title: String,
        facility: String,
        startDate: String,
        endDate: String,
        genre: String
    ) {
        self.performanceId = performanceId
        self.title = title
        self.facility = facility
        self.startDate = startDate
        self.endDate = endDate
        self.genre = genre
    }
}

//
//  WidgetData.swift
//  CurtainCall
//
//  Created by 서준일 on 12/8/25.
//

import Foundation

/// Widget에 표시할 데이터 모델
struct WidgetData: Codable {
    /// 즐겨찾기 공연 목록
    let favoritePerformances: [WidgetPerformance]

    /// 관람 기록 통계
    let statistics: WidgetStatistics

    /// 마지막 업데이트 시간
    let lastUpdated: Date
}

/// Widget용 공연 정보
struct WidgetPerformance: Codable, Identifiable {
    let id: String
    let title: String
    let facility: String
    let poster: String?
    let startDate: String
    let endDate: String
    let genre: String
}

/// Widget용 통계 정보
struct WidgetStatistics: Codable {
    /// 즐겨찾기 개수
    let favoriteCount: Int

    /// 관람 기록 개수
    let recordCount: Int

    /// 가장 많이 본 장르
    let mostViewedGenre: String?

    /// 올해 관람한 공연 수
    let thisYearCount: Int
}

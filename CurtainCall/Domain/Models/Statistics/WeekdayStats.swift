//
//  WeekdayStats.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

/// 요일별 통계
struct WeekdayStats: Hashable {
    let weekday: String              // "월", "화", "수", ...
    let weekdayIndex: Int            // 1(월요일) ~ 7(일요일)
    let count: Int
}

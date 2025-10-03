//
//  AreaStats.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

/// 지역별 통계
struct AreaStats: Hashable {
    let area: String                 // "서울", "경기", ...
    let count: Int
}

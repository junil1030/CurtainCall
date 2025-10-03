//
//  CompanionStats.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

/// 동행인별 통계
struct CompanionStats: Hashable {
    let companion: String            // "혼자", "친구", "가족", "연인"
    let count: Int
}

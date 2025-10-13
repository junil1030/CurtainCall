//
//  GenreStats.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

/// 장르별 통계
struct GenreStats: Hashable {
    let genre: String
    let count: Int
    let percentage: Double
}

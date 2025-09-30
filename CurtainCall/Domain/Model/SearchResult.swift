//
//  SearchResult.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import Foundation

struct SearchResult: Hashable {
    let id: String              // 공연ID
    let title: String           // 공연명
    let startDate: String       // 공연시작일
    let endDate: String         // 공연종료일
    let location: String        // 공연장명
    let posterURL: String       // 포스터 URL
    let area: String            // 지역
    let genre: String           // 장르
    let isOpenRun: Bool         // 오픈런 여부
    let state: String           // 공연상태
    
    // Hashable 구현
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable 구현
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.id == rhs.id
    }
}

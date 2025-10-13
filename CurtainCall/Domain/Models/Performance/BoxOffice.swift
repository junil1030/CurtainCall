//
//  BoxOffice.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation

struct BoxOffice {
    let rank: String
    let title: String
    let location: String
    let posterURL: String
    let performanceID: String
    
    // 찜목록을 위한 추가 필드
    let genre: String
    let area: String
    let performancePeriod: String
    
    var startDate: String {
        return performancePeriod.split(separator: "~")
            .first?
            .trimmingCharacters(in: .whitespaces) ?? "정보없음"
    }
    
    var endDate: String {
        return performancePeriod.split(separator: "~")
            .last?
            .trimmingCharacters(in: .whitespaces) ?? "정보없음"
    }
}

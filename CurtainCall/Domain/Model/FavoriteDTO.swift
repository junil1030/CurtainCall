//
//  FavoriteDTO.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

struct FavoriteDTO {
    let id: String               // 공연 ID
    let title: String            // 공연명
    let posterURL: String        // 포스터 URL
    let location: String         // 공연장
    let startDate: String        // 시작일
    let endDate: String          // 종료일
    let area: String             // 지역
    let genre: String            // 장르
    let createdAt: Date          // 찜한 날짜
    let lastUpdated: Date        // 마지막 업데이트
}

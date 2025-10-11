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
    let posterURL: String?       // 포스터 URL
    let location: String?        // 공연장
    let startDate: String?       // 시작일
    let endDate: String?         // 종료일
    let area: String?            // 지역
    let genre: String?           // 장르
    let createdAt: Date?         // 찜한 날짜
    let lastUpdated: Date?       // 마지막 업데이트
}

extension FavoriteDTO {
    init(
        id: String,
        title: String,
        posterURL: String,
        location: String,
        startDate: String,
        endDate: String,
        area: String,
        genre: String,
        createdAt: Date,
        lastUpdated: Date
    ) {
        self.id = id
        self.title = title
        self.posterURL = posterURL
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.area = area
        self.genre = genre
        self.createdAt = createdAt
        self.lastUpdated = lastUpdated
    }
}

extension FavoriteDTO {
    var safeLocation: String {
        return location ?? "정보없음"
    }
    
    var safePosterURL: String {
        return posterURL ?? ""
    }
    
    var safeStartDate: String {
        return startDate ?? "정보없음"
    }
    
    var safeEndDate: String {
        return endDate ?? "정보없음"
    }
    
    var safeArea: String {
        return area ?? "정보없음"
    }
    
    var safeGenre: String {
        return genre ?? "정보없음"
    }
    
    var safeCreatedAt: Date {
        return createdAt ?? Date()
    }
    
    var safeLastUpdated: Date {
        return lastUpdated ?? Date()
    }
}

//
//  ViewingRecordDTO.swift
//  CurtainCall
//
//  Created by 서준일 on 10/10/25.
//

import Foundation

struct ViewingRecordDTO: Hashable {
    let id: String
    let performanceId: String
    let title: String
    let posterURL: String?
    let area: String?
    let location: String?
    let genre: String?
    let viewingDate: Date
    let rating: Int
    let seat: String
    let companion: String
    let cast: String
    let memo: String
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Safe Access Helpers
extension ViewingRecordDTO {
    var safePosterURL: String {
        return posterURL ?? ""
    }
    
    var safeArea: String {
        return area ?? "정보없음"
    }
    
    var safeLocation: String {
        return location ?? "정보없음"
    }
    
    var safeGenre: String {
        return genre ?? "정보없음"
    }
}

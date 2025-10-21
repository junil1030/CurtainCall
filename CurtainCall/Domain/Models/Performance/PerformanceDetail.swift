//
//  PerformanceDetail.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import Foundation

struct PerformanceDetail: Hashable {
    let id: String
    let title: String
    let startDate: String?
    let endDate: String?
    let area: String?
    let location: String?
    let genre: String?
    let posterURL: String?
    let detailPosterURL: [String]?
    let cast: [String]?
    let bookingSites: [BookingSite]?
    let runtime: String?
    let ageRating: String?
    let ticketPrice: String?
    let producer: String?       // 제작사 (P)
    let planning: String?       // 기획사 (A)
    let host: String?           // 주최 (H)
    let management: String?     // 주관 (S)
    
    var castText: String? {
        guard let cast = cast else { return "" }
        return cast.joined(separator: ", ")
    }
}

struct BookingSite: Hashable {
    let name: String
    let url: String
}

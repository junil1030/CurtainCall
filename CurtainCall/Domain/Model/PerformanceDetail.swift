//
//  PerformanceDetail.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import Foundation

struct PerformanceDetail {
    let id: String
    let title: String
    let startDate: String?
    let endDate: String?
    let area: String?
    let location: String?
    let posterURL: String
    let detailPosterURL: [String]
    let cast: [String]
    let bookingSites: [BookingSite]
    
    var castText: String {
        return cast.joined(separator: ", ")
    }
}

struct BookingSite: Hashable {
    let name: String
    let url: String
}

//
//  RecentSearch.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import Foundation

struct RecentSearch: Equatable {
    let id: String
    let keyword: String
    let searchedAt: Date
    
    init(keyword: String) {
        self.id = UUID().uuidString
        self.keyword = keyword
        self.searchedAt = Date()
    }
}

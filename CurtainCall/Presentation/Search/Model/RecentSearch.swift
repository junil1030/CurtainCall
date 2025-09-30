//
//  RecentSearch.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation

struct RecentSearch: Hashable {
    let id: UUID
    let keyword: String
    let createdAt: Date
    
    init(id: UUID = UUID(), keyword: String, createdAt: Date = Date()) {
        self.id = id
        self.keyword = keyword
        self.createdAt = createdAt
    }
}

//
//  RecentSearchKeyword.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation
import RealmSwift

class RecentSearchKeyword: Object {
    @Persisted(primaryKey: true) var id: ObjectId             // 자동 생성 ID
    @Persisted var keyword: String                            // 검색어
    @Persisted var createdAt: Date                            // 검색 날짜
    
    convenience init(keyword: String) {
        self.init()
        self.keyword = keyword
        self.createdAt = Date()
    }
}

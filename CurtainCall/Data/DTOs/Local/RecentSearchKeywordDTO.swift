//
//  RecentSearchKeywordDTO.swift
//  CurtainCall
//
//  Created by 서준일 on 10/13/25.
//

import Foundation

struct RecentSearchKeywordDTO {
    let id: String          // primary key
    let keyword: String     // 검색어
    let createdAt: Date     // 검색 날짜
}

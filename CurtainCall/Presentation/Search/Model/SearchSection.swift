//
//  SearchSection.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation

enum SearchSection: Int, CaseIterable {
    case recentSearch
    case searchResult
    case filter
    case empty
    case noResult
}

enum SearchItem: Hashable {
    case recentSearch(RecentSearch)
    case searchResult(SearchResult)
    case filter
    case empty
    case noResult
}

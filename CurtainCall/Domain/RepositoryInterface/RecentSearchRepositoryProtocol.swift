//
//  RecentSearchRepositoryProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation
import RealmSwift

protocol RecentSearchRepositoryProtocol {
    // Create
    func addSearch(_ keyword: String) throws
    
    // Read
    func getRecentSearches(limit: Int) -> [RecentSearch]
    func searchKeyword(_ keyword: String) -> [RecentSearch]
    func getSearchCount() -> Int
    
    // Delete
    func deleteSearch(id: ObjectId) throws
    func deleteSearchByKeyword(_ keyword: String) throws
    func clearAllSearches() throws
    
    // Utility
    func clearOldSearches(olderThan days: Int) throws
}

//나는 DiffableDataSource를 사용하고 있어서 이걸 struct로 변환해줘야해 그래서 각각 UI에서 사용할 모델을 만들고 양방향으로 변환해줄 매퍼를 구성해줘.

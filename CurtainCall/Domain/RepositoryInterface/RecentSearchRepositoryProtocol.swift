//
//  RecentSearchRepositoryProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation
import RealmSwift

protocol RecentSearchRepositoryProtocol {
    func addSearch(_ keyword: String) throws
    func getRecentSearches(limit: Int) -> [RecentSearch]
    func deleteSearch(id: ObjectId) throws
    func clearAllSearches() throws
}

//
//  GetRecentSearchesUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/12/25.
//

import Foundation

import Foundation

final class GetRecentSearchesUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = Void
    typealias Output = [RecentSearch]
    
    // MARK: - Properties
    private let repository: RecentSearchRepositoryProtocol
    private let maxCount = 5  // 최대 5개까지만 조회
    
    // MARK: - Init
    init(repository: RecentSearchRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: Void) -> [RecentSearch] {
        return repository.getRecentSearches(limit: maxCount)
    }
}

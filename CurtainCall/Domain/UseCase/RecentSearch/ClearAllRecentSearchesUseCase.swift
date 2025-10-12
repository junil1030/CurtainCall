//
//  ClearAllRecentSearchesUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/12/25.
//

import Foundation

final class ClearAllRecentSearchesUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = Void
    typealias Output = Result<Void, Error>
    
    // MARK: - Properties
    private let repository: RecentSearchRepositoryProtocol
    
    // MARK: - Init
    init(repository: RecentSearchRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: Void) -> Result<Void, Error> {
        do {
            try repository.clearAllSearches()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

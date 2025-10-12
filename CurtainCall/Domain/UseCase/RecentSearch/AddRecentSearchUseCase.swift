//
//  AddRecentSearchUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/12/25.
//

import Foundation

final class AddRecentSearchUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = String // keyword
    typealias Output = Result<Void, Error>
    
    // MARK: - Properties
    private let repository: RecentSearchRepositoryProtocol
    
    // MARK: - Init
    init(repository: RecentSearchRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: String) -> Result<Void, any Error> {
        do {
            try repository.addSearch(input)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

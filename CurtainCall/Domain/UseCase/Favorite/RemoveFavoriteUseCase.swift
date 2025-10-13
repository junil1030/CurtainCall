//
//  RemoveFavoriteUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import Foundation

final class RemoveFavoriteUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = String  // performanceID
    typealias Output = Result<Void, Error>
    
    // MARK: - Properties
    private let repository: FavoriteRepositoryProtocol
    
    // MARK: - Init
    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: String) -> Result<Void, Error> {
        do {
            try repository.removeFavorite(id: input)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

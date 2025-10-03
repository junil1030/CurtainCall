//
//  CheckFavoriteStatusUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

final class CheckFavoriteStatusUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = String  // performanceID
    typealias Output = Bool
    
    // MARK: - Properties
    private let repository: FavoriteRepositoryProtocol
    
    // MARK: - Init
    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: String) -> Bool {
        return repository.isFavorite(id: input)
    }
}

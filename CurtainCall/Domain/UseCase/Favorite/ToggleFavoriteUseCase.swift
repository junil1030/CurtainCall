//
//  ToggleFavoriteUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

final class ToggleFavoriteUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = FavoriteDTO
    typealias Output = Result<Bool, Error>
    
    // MARK: - Properties
    private let repository: FavoriteRepositoryProtocol
    
    // MARK: - Init
    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: FavoriteDTO) -> Result<Bool, Error> {
        do {
            let isFavorite = try repository.toggleFavorite(input)
            return .success(isFavorite)
        } catch {
            return .failure(error)
        }
    }
}

//
//  GetFavoriteStatisticsuseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import Foundation

final class GetFavoriteStatisticsUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = Void
    typealias Output = FavoriteStatistics
    
    // MARK: - Properties
    private let repository: FavoriteRepositoryProtocol
    
    // MARK: - Init
    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: Void) -> FavoriteStatistics {
        return repository.getFavoriteStatistics()
    }
}

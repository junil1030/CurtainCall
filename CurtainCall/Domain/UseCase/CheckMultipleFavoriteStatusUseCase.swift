//
//  CheckMultipleFavoriteStatusUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

final class CheckMultipleFavoriteStatusUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = [String]  // performanceIDs
    typealias Output = [String: Bool]  // [performanceID: isFavorite]
    
    // MARK: - Properties
    private let repository: FavoriteRepositoryProtocol
    
    // MARK: - Init
    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: [String]) -> [String: Bool] {
        var result: [String: Bool] = [:]
        
        for performanceID in input {
            result[performanceID] = repository.isFavorite(id: performanceID)
        }
        
        return result
    }
}

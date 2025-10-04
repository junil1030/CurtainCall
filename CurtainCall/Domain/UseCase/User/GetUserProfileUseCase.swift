//
//  GetUserProfileUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import Foundation

final class GetUserProfileUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = Void
    typealias Output = UserProfile?
    
    // MARK: - Properties
    private let repository: UserRepositoryProtocol
    
    // MARK: - Init
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: Void) -> UserProfile? {
        return repository.getUser()
    }
}

//
//  UpdateNicknameUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import Foundation

final class UpdateNicknameUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = String
    typealias Output = Result<Void, Error>
    
    // MARK: - Properties
    private let repository: UserRepositoryProtocol
    
    // MARK: - Init
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: String) -> Result<Void, Error> {
        // 1. 유효성 검사
        let trimmedNickname = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedNickname.isEmpty else {
            return .failure(NicknameValidationError.empty)
        }
        
        guard trimmedNickname.count <= 10 else {
            return .failure(NicknameValidationError.tooLong)
        }
        
        // 2. Repository를 통해 업데이트
        do {
            try repository.updateNickname(trimmedNickname)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - Error Definition
enum NicknameValidationError: LocalizedError {
    case empty
    case tooLong
    
    var errorDescription: String? {
        switch self {
        case .empty:
            return "닉네임을 입력해주세요."
        case .tooLong:
            return "닉네임은 10자 이하로 입력해주세요."
        }
    }
}

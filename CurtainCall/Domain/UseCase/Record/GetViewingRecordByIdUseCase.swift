//
//  GetViewingRecordByIdUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/11/25.
//

import Foundation

final class GetViewingRecordByIdUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = String
    typealias Output = ViewingRecordDTO?
    
    // MARK: - Properties
    private let repository: ViewingRecordRepositoryProtocol
    
    // MARK: - Init
    init(repository: ViewingRecordRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: String) -> ViewingRecordDTO? {
        // Stiring id로 기록 조회
        guard let record = repository.getRecord(by: input) else {
            return nil
        }
        
        return ViewingRecordRealmMapper.toDomain(record)
    }
}

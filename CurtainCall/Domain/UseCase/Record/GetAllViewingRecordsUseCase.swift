//
//  GetAllViewingRecordsUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/10/25.
//

import Foundation

final class GetAllViewingRecordsUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = Void
    typealias Output = [ViewingRecordDTO]
    
    // MARK: - Properties
    private let repository: ViewingRecordRepositoryProtocol
    
    // MARK: - Init
    init(repository: ViewingRecordRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: Void) -> [ViewingRecordDTO] {
        let records = repository.getRecords()
        return ViewingRecordRealmMapper.toDomainList(records)
    }
}

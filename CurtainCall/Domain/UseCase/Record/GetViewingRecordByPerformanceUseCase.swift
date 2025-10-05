//
//  GetViewingRecordByPerformanceUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/5/25.
//

import Foundation

final class GetViewingRecordByPerformanceUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = String  // performanceId
    typealias Output = ViewingRecord?
    
    // MARK: - Properties
    private let repository: ViewingRecordRepositoryProtocol
    
    // MARK: - Init
    init(repository: ViewingRecordRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: String) -> ViewingRecord? {
        // 해당 공연의 기록 조회 (같은 공연은 1개만 허용)
        let records = repository.getRecordsByPerformance(performanceId: input)
        
        // 가장 최근 기록 반환 (이미 날짜 내림차순 정렬되어 있음)
        return records.first
    }
}

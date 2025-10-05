//
//  UpdateViewingRecordUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/5/25.
//

import Foundation
import RealmSwift

final class UpdateViewingRecordUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = ViewingRecordUpdateInput
    typealias Output = Result<Void, Error>
    
    // MARK: - Properties
    private let repository: ViewingRecordRepositoryProtocol
    
    // MARK: - Init
    init(repository: ViewingRecordRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: ViewingRecordUpdateInput) -> Result<Void, Error> {
        do {
            // 1. 기존 기록 조회
            guard let existingRecord = repository.getRecord(by: input.recordId) else {
                throw UpdateViewingRecordError.recordNotFound
            }
            
            // 2. 날짜와 시간 결합
            let viewingDateTime = try combineDateAndTime(
                date: input.viewingDate,
                time: input.viewingTime
            )
            
            // 3. Realm의 thaw()를 사용하여 수정 가능한 복사본 생성
            // 또는 Repository의 write 블록 안에서 수정
            try repository.updateRecordFields(
                id: input.recordId,
                viewingDate: viewingDateTime,
                companion: input.companion,
                seat: input.seat,
                rating: input.rating,
                memo: input.review
            )
            
            return .success(())
            
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Private Methods
    private func combineDateAndTime(date: Date, time: Date) throws -> Date {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        guard let combinedDate = calendar.date(from: combinedComponents) else {
            throw ViewingRecordError.invalidDateFormat
        }
        
        return combinedDate
    }
}

// MARK: - Input DTO
struct ViewingRecordUpdateInput {
    let recordId: ObjectId
    let viewingDate: Date
    let viewingTime: Date
    let companion: String
    let seat: String
    let rating: Int
    let review: String
}

// MARK: - Error
enum UpdateViewingRecordError: LocalizedError {
    case recordNotFound
    
    var errorDescription: String? {
        switch self {
        case .recordNotFound:
            return "수정할 기록을 찾을 수 없습니다."
        }
    }
}

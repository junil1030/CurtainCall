//
//  AddViewingRecordUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/5/25.
//

import Foundation
import OSLog

final class AddViewingRecordUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = ViewingRecordInput
    typealias Output = Result<Void, Error>
    
    // MARK: - Properties
    private let repository: ViewingRecordRepositoryProtocol
    
    // MARK: - Init
    init(repository: ViewingRecordRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Execute
    func execute(_ input: ViewingRecordInput) -> Result<Void, Error> {
        do {
            // 1. 날짜와 시간 결합
            let viewingDateTime = try combineDateAndTime(
                date: input.viewingDate,
                time: input.viewingTime
            )
            
            // 2. ViewingRecord 생성
            let record = ViewingRecord(
                from: input.performanceDetail,
                viewingDate: viewingDateTime
            )
            
            // 3. 필수 필드 채우기
            record.companion = input.companion
            record.seat = input.seat
            record.rating = input.rating
            record.memo = input.review
            
            // 4. Repository를 통해 저장
            try repository.addRecord(record)
            
            Logger.config.info("저장: \(record.title)")
            
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
struct ViewingRecordInput {
    let performanceDetail: PerformanceDetail
    let viewingDate: Date
    let viewingTime: Date
    let companion: String
    let seat: String
    let rating: Int
    let review: String
}

// MARK: - Error
enum ViewingRecordError: LocalizedError {
    case invalidDateFormat
    case invalidRating
    case missingRequiredField
    
    var errorDescription: String? {
        switch self {
        case .invalidDateFormat:
            return "날짜 형식이 올바르지 않습니다."
        case .invalidRating:
            return "별점은 0~5 사이여야 합니다."
        case .missingRequiredField:
            return "필수 입력값이 누락되었습니다."
        }
    }
}

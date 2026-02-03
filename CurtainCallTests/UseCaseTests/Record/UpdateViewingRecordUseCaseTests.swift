//
//  UpdateViewingRecordUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
import RealmSwift
@testable import CurtainCall

final class UpdateViewingRecordUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: UpdateViewingRecordUseCase!
    private var mockRepository: MockViewingRecordRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockViewingRecordRepository()
        sut = UpdateViewingRecordUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests - Success Cases
    func test_execute_withValidInput_updatesRecordSuccessfully() {
        // Given
        let record = createViewingRecord(title: "원본 공연")
        mockRepository.addRecordDirect(record)

        let calendar = Calendar.current
        let newViewingDate = calendar.date(from: DateComponents(year: 2025, month: 2, day: 20))!
        let newViewingTime = calendar.date(from: DateComponents(hour: 14, minute: 0))!

        let updateInput = ViewingRecordUpdateInput(
            recordId: record.id.stringValue,
            viewingDate: newViewingDate,
            viewingTime: newViewingTime,
            companion: "가족",
            seat: "VIP석 1열 1번",
            rating: 4,
            review: "수정된 감상평"
        )

        // When
        let result = sut.execute(updateInput)

        // Then
        switch result {
        case .success:
            let updatedRecord = mockRepository.getRecord(by: record.id.stringValue)!
            XCTAssertEqual(updatedRecord.companion, "가족", "동행인이 업데이트되어야 합니다.")
            XCTAssertEqual(updatedRecord.seat, "VIP석 1열 1번", "좌석이 업데이트되어야 합니다.")
            XCTAssertEqual(updatedRecord.rating, 4, "별점이 업데이트되어야 합니다.")
            XCTAssertEqual(updatedRecord.memo, "수정된 감상평", "감상평이 업데이트되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_updatesDateAndTimeCorrectly() {
        // Given
        let record = createViewingRecord(title: "테스트 공연")
        mockRepository.addRecordDirect(record)

        let calendar = Calendar.current
        let newViewingDate = calendar.date(from: DateComponents(year: 2025, month: 3, day: 10))!
        let newViewingTime = calendar.date(from: DateComponents(hour: 18, minute: 45))!

        let updateInput = ViewingRecordUpdateInput(
            recordId: record.id.stringValue,
            viewingDate: newViewingDate,
            viewingTime: newViewingTime,
            companion: "친구",
            seat: "S석",
            rating: 5,
            review: "좋아요"
        )

        // When
        let result = sut.execute(updateInput)

        // Then
        switch result {
        case .success:
            let updatedRecord = mockRepository.getRecord(by: record.id.stringValue)!
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: updatedRecord.viewingDate)

            XCTAssertEqual(components.year, 2025, "년도가 업데이트되어야 합니다.")
            XCTAssertEqual(components.month, 3, "월이 업데이트되어야 합니다.")
            XCTAssertEqual(components.day, 10, "일이 업데이트되어야 합니다.")
            XCTAssertEqual(components.hour, 18, "시간이 업데이트되어야 합니다.")
            XCTAssertEqual(components.minute, 45, "분이 업데이트되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_doesNotChangeOtherRecords() {
        // Given
        let record1 = createViewingRecord(title: "공연1")
        let record2 = createViewingRecord(title: "공연2")
        mockRepository.addRecordDirect(record1)
        mockRepository.addRecordDirect(record2)

        let updateInput = ViewingRecordUpdateInput(
            recordId: record1.id.stringValue,
            viewingDate: Date(),
            viewingTime: Date(),
            companion: "업데이트된 동행인",
            seat: "업데이트된 좌석",
            rating: 3,
            review: "업데이트된 감상평"
        )

        // When
        let result = sut.execute(updateInput)

        // Then
        switch result {
        case .success:
            let updatedRecord1 = mockRepository.getRecord(by: record1.id.stringValue)!
            let unchangedRecord2 = mockRepository.getRecord(by: record2.id.stringValue)!

            XCTAssertEqual(updatedRecord1.companion, "업데이트된 동행인", "record1은 업데이트되어야 합니다.")
            XCTAssertEqual(unchangedRecord2.companion, "혼자", "record2는 변경되지 않아야 합니다.")
            XCTAssertEqual(unchangedRecord2.title, "공연2", "record2의 제목은 유지되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_updatesOnlySpecifiedFields() {
        // Given
        let record = createViewingRecord(title: "원본 공연", performanceId: "perf123")
        mockRepository.addRecordDirect(record)

        let originalTitle = record.title
        let originalPerformanceId = record.performanceId

        let updateInput = ViewingRecordUpdateInput(
            recordId: record.id.stringValue,
            viewingDate: Date(),
            viewingTime: Date(),
            companion: "새 동행인",
            seat: "새 좌석",
            rating: 5,
            review: "새 감상평"
        )

        // When
        let result = sut.execute(updateInput)

        // Then
        switch result {
        case .success:
            let updatedRecord = mockRepository.getRecord(by: record.id.stringValue)!

            // 업데이트된 필드
            XCTAssertEqual(updatedRecord.companion, "새 동행인", "동행인은 업데이트되어야 합니다.")
            XCTAssertEqual(updatedRecord.seat, "새 좌석", "좌석은 업데이트되어야 합니다.")
            XCTAssertEqual(updatedRecord.rating, 5, "별점은 업데이트되어야 합니다.")
            XCTAssertEqual(updatedRecord.memo, "새 감상평", "감상평은 업데이트되어야 합니다.")

            // 업데이트되지 않은 필드
            XCTAssertEqual(updatedRecord.title, originalTitle, "공연명은 변경되지 않아야 합니다.")
            XCTAssertEqual(updatedRecord.performanceId, originalPerformanceId, "공연 ID는 변경되지 않아야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    // MARK: - Tests - Error Handling
    func test_execute_whenRecordNotFound_returnsFailure() {
        // Given
        let nonExistentId = UUID().uuidString
        let updateInput = ViewingRecordUpdateInput(
            recordId: nonExistentId,
            viewingDate: Date(),
            viewingTime: Date(),
            companion: "동행인",
            seat: "좌석",
            rating: 5,
            review: "감상평"
        )

        // When
        let result = sut.execute(updateInput)

        // Then
        switch result {
        case .success:
            XCTFail("존재하지 않는 레코드는 업데이트 실패해야 합니다.")
        case .failure(let error):
            XCTAssertNotNil(error, "에러가 발생해야 합니다.")
        }
    }

    func test_execute_whenRepositoryThrowsError_returnsFailure() {
        // Given
        let record = createViewingRecord(title: "테스트 공연")
        mockRepository.addRecordDirect(record)
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NSError(domain: "TestError", code: 500, userInfo: nil)

        let updateInput = ViewingRecordUpdateInput(
            recordId: record.id.stringValue,
            viewingDate: Date(),
            viewingTime: Date(),
            companion: "동행인",
            seat: "좌석",
            rating: 5,
            review: "감상평"
        )

        // When
        let result = sut.execute(updateInput)

        // Then
        switch result {
        case .success:
            XCTFail("에러가 발생해야 합니다.")
        case .failure(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "TestError", "에러 도메인이 일치해야 합니다.")
            XCTAssertEqual(nsError.code, 500, "에러 코드가 일치해야 합니다.")
        }
    }

    // MARK: - Helper Methods
    private func createViewingRecord(
        title: String,
        performanceId: String = "perf001",
        companion: String = "혼자",
        seat: String = "R석 10열 5번",
        rating: Int = 5,
        memo: String = "좋았어요!"
    ) -> ViewingRecord {
        let record = ViewingRecord()
        record.performanceId = performanceId
        record.title = title
        record.posterURL = "https://example.com/poster.jpg"
        record.area = AreaCode.seoul.rawValue
        record.location = "테스트 극장"
        record.genre = GenreCode.musical.rawValue
        record.viewingDate = Date()
        record.companion = companion
        record.seat = seat
        record.rating = rating
        record.memo = memo
        record.createdAt = Date()
        record.updatedAt = Date()
        return record
    }
}

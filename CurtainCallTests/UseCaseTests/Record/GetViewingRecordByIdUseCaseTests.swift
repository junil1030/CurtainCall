//
//  GetViewingRecordByIdUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
import RealmSwift
@testable import CurtainCall

final class GetViewingRecordByIdUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: GetViewingRecordByIdUseCase!
    private var mockRepository: MockViewingRecordRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockViewingRecordRepository()
        sut = GetViewingRecordByIdUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests - Success Cases
    func test_execute_whenRecordExists_returnsDTO() {
        // Given
        let record = createViewingRecord(title: "테스트 공연", performanceId: "perf001")
        mockRepository.addRecordDirect(record)

        // When
        let result = sut.execute(record.id.stringValue)

        // Then
        XCTAssertNotNil(result, "레코드가 존재하면 DTO를 반환해야 합니다.")
        XCTAssertEqual(result?.title, "테스트 공연", "공연 제목이 일치해야 합니다.")
        XCTAssertEqual(result?.performanceId, "perf001", "공연 ID가 일치해야 합니다.")
    }

    func test_execute_returnsDTOWithCorrectFields() {
        // Given
        let record = createViewingRecord(
            title: "뮤지컬 테스트",
            performanceId: "perf123",
            companion: "친구",
            seat: "VIP석 1열 1번",
            rating: 5,
            memo: "최고였어요!"
        )
        mockRepository.addRecordDirect(record)

        // When
        let result = sut.execute(record.id.stringValue)

        // Then
        XCTAssertNotNil(result, "DTO가 반환되어야 합니다.")
        XCTAssertEqual(result?.id, record.id.stringValue, "ID가 일치해야 합니다.")
        XCTAssertEqual(result?.title, "뮤지컬 테스트", "제목이 일치해야 합니다.")
        XCTAssertEqual(result?.performanceId, "perf123", "공연 ID가 일치해야 합니다.")
        XCTAssertEqual(result?.companion, "친구", "동행인이 일치해야 합니다.")
        XCTAssertEqual(result?.seat, "VIP석 1열 1번", "좌석이 일치해야 합니다.")
        XCTAssertEqual(result?.rating, 5, "별점이 일치해야 합니다.")
        XCTAssertEqual(result?.memo, "최고였어요!", "감상평이 일치해야 합니다.")
    }

    func test_execute_convertsGenreCodeToDisplayName() {
        // Given
        let record = createViewingRecord(title: "뮤지컬", performanceId: "perf001")
        record.genre = GenreCode.musical.rawValue  // "GGGA"
        mockRepository.addRecordDirect(record)

        // When
        let result = sut.execute(record.id.stringValue)

        // Then
        XCTAssertNotNil(result, "DTO가 반환되어야 합니다.")
        XCTAssertEqual(result?.genre, GenreCode.musical.displayName, "장르 코드가 표시명으로 변환되어야 합니다.")
    }

    func test_execute_returnsCorrectRecordAmongMultiple() {
        // Given
        let record1 = createViewingRecord(title: "공연1", performanceId: "perf001")
        let record2 = createViewingRecord(title: "공연2", performanceId: "perf002")
        let record3 = createViewingRecord(title: "공연3", performanceId: "perf003")
        mockRepository.addRecordDirect(record1)
        mockRepository.addRecordDirect(record2)
        mockRepository.addRecordDirect(record3)

        // When
        let result = sut.execute(record2.id.stringValue)

        // Then
        XCTAssertNotNil(result, "레코드가 반환되어야 합니다.")
        XCTAssertEqual(result?.id, record2.id.stringValue, "올바른 레코드를 반환해야 합니다.")
        XCTAssertEqual(result?.title, "공연2", "공연2가 반환되어야 합니다.")
        XCTAssertEqual(result?.performanceId, "perf002", "공연 ID가 일치해야 합니다.")
    }

    func test_execute_includesPerformanceDetails() {
        // Given
        let record = createViewingRecord(
            title: "테스트 공연",
            performanceId: "perf001"
        )
        record.posterURL = "https://example.com/poster.jpg"
        record.area = AreaCode.seoul.rawValue
        record.location = "세종문화회관"
        mockRepository.addRecordDirect(record)

        // When
        let result = sut.execute(record.id.stringValue)

        // Then
        XCTAssertNotNil(result, "DTO가 반환되어야 합니다.")
        XCTAssertEqual(result?.posterURL, "https://example.com/poster.jpg", "포스터 URL이 일치해야 합니다.")
        XCTAssertEqual(result?.area, AreaCode.seoul.rawValue, "지역이 일치해야 합니다.")
        XCTAssertEqual(result?.location, "세종문화회관", "공연장이 일치해야 합니다.")
    }

    // MARK: - Tests - Not Found Cases
    func test_execute_whenRecordNotFound_returnsNil() {
        // Given
        let nonExistentId = ObjectId().stringValue

        // When
        let result = sut.execute(nonExistentId)

        // Then
        XCTAssertNil(result, "존재하지 않는 레코드는 nil을 반환해야 합니다.")
    }

    func test_execute_withInvalidId_returnsNil() {
        // Given
        let invalidId = "invalid-id-format"

        // When
        let result = sut.execute(invalidId)

        // Then
        XCTAssertNil(result, "잘못된 형식의 ID는 nil을 반환해야 합니다.")
    }

    func test_execute_whenRepositoryIsEmpty_returnsNil() {
        // Given
        let anyId = ObjectId().stringValue

        // When
        let result = sut.execute(anyId)

        // Then
        XCTAssertNil(result, "저장소가 비어있으면 nil을 반환해야 합니다.")
    }

    func test_execute_afterRecordDeleted_returnsNil() {
        // Given
        let record = createViewingRecord(title: "테스트 공연", performanceId: "perf0001")
        mockRepository.addRecordDirect(record)
        let recordId = record.id.stringValue

        // 레코드 삭제
        try? mockRepository.deleteRecord(id: recordId)

        // When
        let result = sut.execute(recordId)

        // Then
        XCTAssertNil(result, "삭제된 레코드는 nil을 반환해야 합니다.")
    }

    // MARK: - Helper Methods
    private func createViewingRecord(
        title: String,
        performanceId: String,
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

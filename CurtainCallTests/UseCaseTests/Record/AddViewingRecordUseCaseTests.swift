//
//  AddViewingRecordUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class AddViewingRecordUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: AddViewingRecordUseCase!
    private var mockRepository: MockViewingRecordRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockViewingRecordRepository()
        sut = AddViewingRecordUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests - Success Cases
    func test_execute_withValidInput_addsRecordSuccessfully() {
        // Given
        let performanceDetail = createPerformanceDetail(id: "perf001", title: "테스트 공연")
        let input = createViewingRecordInput(performanceDetail: performanceDetail)

        // When
        let result = sut.execute(input)

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getRecordCount(), 1, "레코드가 1개 추가되어야 합니다.")
            let records = mockRepository.getRecords()
            XCTAssertEqual(records.first?.title, "테스트 공연", "공연 제목이 일치해야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_combinesDateAndTimeCorrectly() {
        // Given
        let performanceDetail = createPerformanceDetail(id: "perf001", title: "테스트 공연")

        let calendar = Calendar.current
        let viewingDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let viewingTime = calendar.date(from: DateComponents(hour: 19, minute: 30))!

        let input = createViewingRecordInput(
            performanceDetail: performanceDetail,
            viewingDate: viewingDate,
            viewingTime: viewingTime
        )

        // When
        let result = sut.execute(input)

        // Then
        switch result {
        case .success:
            let records = mockRepository.getRecords()
            let savedRecord = records.first!

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: savedRecord.viewingDate)
            XCTAssertEqual(components.year, 2025, "년도가 일치해야 합니다.")
            XCTAssertEqual(components.month, 1, "월이 일치해야 합니다.")
            XCTAssertEqual(components.day, 15, "일이 일치해야 합니다.")
            XCTAssertEqual(components.hour, 19, "시간이 일치해야 합니다.")
            XCTAssertEqual(components.minute, 30, "분이 일치해야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_savesAllFields() {
        // Given
        let performanceDetail = createPerformanceDetail(id: "perf001", title: "테스트 공연")
        let input = createViewingRecordInput(
            performanceDetail: performanceDetail,
            companion: "친구",
            seat: "R석 10열 5번",
            rating: 5,
            review: "정말 재미있었어요!"
        )

        // When
        let result = sut.execute(input)

        // Then
        switch result {
        case .success:
            let records = mockRepository.getRecords()
            let savedRecord = records.first!

            XCTAssertEqual(savedRecord.companion, "친구", "동행인이 저장되어야 합니다.")
            XCTAssertEqual(savedRecord.seat, "R석 10열 5번", "좌석 정보가 저장되어야 합니다.")
            XCTAssertEqual(savedRecord.rating, 5, "별점이 저장되어야 합니다.")
            XCTAssertEqual(savedRecord.memo, "정말 재미있었어요!", "감상평이 저장되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_addsMultipleRecords() {
        // Given
        let performanceDetail1 = createPerformanceDetail(id: "perf001", title: "공연1")
        let performanceDetail2 = createPerformanceDetail(id: "perf002", title: "공연2")
        let input1 = createViewingRecordInput(performanceDetail: performanceDetail1)
        let input2 = createViewingRecordInput(performanceDetail: performanceDetail2)

        // When
        let result1 = sut.execute(input1)
        let result2 = sut.execute(input2)

        // Then
        switch (result1, result2) {
        case (.success, .success):
            XCTAssertEqual(mockRepository.getRecordCount(), 2, "2개의 레코드가 추가되어야 합니다.")
        default:
            XCTFail("모든 추가가 성공해야 합니다.")
        }
    }

    func test_execute_savesPerformanceDetailsCorrectly() {
        // Given
        let performanceDetail = createPerformanceDetail(
            id: "perf001",
            title: "테스트 뮤지컬",
            genre: GenreCode.musical.displayName,
            area: AreaCode.seoul.rawValue,
            location: "LG아트센터",
            posterURL: "https://example.com/poster.jpg"
        )
        let input = createViewingRecordInput(performanceDetail: performanceDetail)

        // When
        let result = sut.execute(input)

        // Then
        switch result {
        case .success:
            let records = mockRepository.getRecords()
            let savedRecord = records.first!

            XCTAssertEqual(savedRecord.performanceId, "perf001", "공연 ID가 저장되어야 합니다.")
            XCTAssertEqual(savedRecord.title, "테스트 뮤지컬", "공연명이 저장되어야 합니다.")
            XCTAssertEqual(savedRecord.location, "LG아트센터", "공연장이 저장되어야 합니다.")
            XCTAssertEqual(savedRecord.posterURL, "https://example.com/poster.jpg", "포스터 URL이 저장되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    // MARK: - Tests - Error Handling
    func test_execute_whenRepositoryThrowsError_returnsFailure() {
        // Given
        let performanceDetail = createPerformanceDetail(id: "perf001", title: "테스트 공연")
        let input = createViewingRecordInput(performanceDetail: performanceDetail)
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NSError(domain: "TestError", code: 500, userInfo: nil)

        // When
        let result = sut.execute(input)

        // Then
        switch result {
        case .success:
            XCTFail("에러가 발생해야 합니다.")
        case .failure(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "TestError", "에러 도메인이 일치해야 합니다.")
            XCTAssertEqual(nsError.code, 500, "에러 코드가 일치해야 합니다.")
            XCTAssertEqual(mockRepository.getRecordCount(), 0, "레코드가 추가되지 않아야 합니다.")
        }
    }

    // MARK: - Helper Methods
    private func createPerformanceDetail(
        id: String,
        title: String,
        genre: String? = GenreCode.musical.displayName,
        area: String? = AreaCode.seoul.rawValue,
        location: String? = "테스트 극장",
        posterURL: String? = "https://example.com/poster.jpg"
    ) -> PerformanceDetail {
        return PerformanceDetail(
            id: id,
            title: title,
            startDate: "2025-01-01",
            endDate: "2025-12-31",
            area: area,
            location: location,
            genre: genre,
            posterURL: posterURL,
            detailPosterURL: nil,
            cast: ["배우1", "배우2"],
            bookingSites: nil,
            runtime: "120분",
            ageRating: "12세이상",
            ticketPrice: "70,000원",
            producer: "제작사",
            planning: "기획사",
            host: "주최",
            management: "주관"
        )
    }

    private func createViewingRecordInput(
        performanceDetail: PerformanceDetail,
        viewingDate: Date = Date(),
        viewingTime: Date = Date(),
        companion: String = "혼자",
        seat: String = "R석 10열 5번",
        rating: Int = 5,
        review: String = "좋았어요!"
    ) -> ViewingRecordInput {
        return ViewingRecordInput(
            performanceDetail: performanceDetail,
            viewingDate: viewingDate,
            viewingTime: viewingTime,
            companion: companion,
            seat: seat,
            rating: rating,
            review: review
        )
    }
}

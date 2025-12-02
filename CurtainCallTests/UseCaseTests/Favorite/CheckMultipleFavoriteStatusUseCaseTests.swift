//
//  CheckMultipleFavoriteStatusUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class CheckMultipleFavoriteStatusUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: CheckMultipleFavoriteStatusUseCase!
    private var mockRepository: MockFavoriteRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockFavoriteRepository()
        sut = CheckMultipleFavoriteStatusUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests
    func test_execute_withMultiplePerformanceIDs_returnsCorrectStatus() {
        // Given
        let favorite1 = createFavoriteDTO(id: "perf001")
        let favorite2 = createFavoriteDTO(id: "perf002")
        mockRepository.addFavorite(favorite1)
        mockRepository.addFavorite(favorite2)

        let performanceIDs = ["perf001", "perf002", "perf003"]

        // When
        let result = sut.execute(performanceIDs)

        // Then
        XCTAssertEqual(result.count, 3, "결과는 입력한 ID 수만큼 반환되어야 합니다.")
        XCTAssertTrue(result["perf001"] ?? false, "perf001은 찜 상태여야 합니다.")
        XCTAssertTrue(result["perf002"] ?? false, "perf002는 찜 상태여야 합니다.")
        XCTAssertFalse(result["perf003"] ?? true, "perf003은 찜 상태가 아니어야 합니다.")
    }

    func test_execute_withEmptyArray_returnsEmptyDictionary() {
        // Given
        let performanceIDs: [String] = []

        // When
        let result = sut.execute(performanceIDs)

        // Then
        XCTAssertTrue(result.isEmpty, "빈 배열을 입력하면 빈 딕셔너리를 반환해야 합니다.")
    }

    func test_execute_whenNoFavoritesExist_returnsAllFalse() {
        // Given
        let performanceIDs = ["perf001", "perf002", "perf003"]

        // When
        let result = sut.execute(performanceIDs)

        // Then
        XCTAssertEqual(result.count, 3, "결과는 입력한 ID 수만큼 반환되어야 합니다.")
        for (id, isFavorite) in result {
            XCTAssertFalse(isFavorite, "\(id)는 찜 상태가 아니어야 합니다.")
        }
    }

    func test_execute_whenAllFavoritesExist_returnsAllTrue() {
        // Given
        let favorite1 = createFavoriteDTO(id: "perf001")
        let favorite2 = createFavoriteDTO(id: "perf002")
        let favorite3 = createFavoriteDTO(id: "perf003")
        mockRepository.addFavorite(favorite1)
        mockRepository.addFavorite(favorite2)
        mockRepository.addFavorite(favorite3)

        let performanceIDs = ["perf001", "perf002", "perf003"]

        // When
        let result = sut.execute(performanceIDs)

        // Then
        XCTAssertEqual(result.count, 3, "결과는 입력한 ID 수만큼 반환되어야 합니다.")
        for (id, isFavorite) in result {
            XCTAssertTrue(isFavorite, "\(id)는 찜 상태여야 합니다.")
        }
    }

    func test_execute_withDuplicateIDs_returnsMappedValues() {
        // Given
        let favorite1 = createFavoriteDTO(id: "perf001")
        mockRepository.addFavorite(favorite1)

        let performanceIDs = ["perf001", "perf001", "perf002"]

        // When
        let result = sut.execute(performanceIDs)

        // Then
        XCTAssertTrue(result["perf001"] ?? false, "perf001은 찜 상태여야 합니다.")
        XCTAssertFalse(result["perf002"] ?? true, "perf002는 찜 상태가 아니어야 합니다.")
    }

    // MARK: - Helper Methods
    private func createFavoriteDTO(
        id: String,
        title: String = "테스트 공연",
        genre: String? = GenreCode.musical.rawValue,
        area: String? = AreaCode.seoul.rawValue
    ) -> FavoriteDTO {
        return FavoriteDTO(
            id: id,
            title: title,
            posterURL: "https://example.com/poster.jpg",
            location: "테스트 극장",
            startDate: "2025-01-01",
            endDate: "2025-12-31",
            area: area,
            genre: genre,
            createdAt: Date(),
            lastUpdated: Date()
        )
    }
}

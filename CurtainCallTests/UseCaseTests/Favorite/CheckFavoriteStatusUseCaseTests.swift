//
//  CheckFavoriteStatusUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class CheckFavoriteStatusUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: CheckFavoriteStatusUseCase!
    private var mockRepository: MockFavoriteRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockFavoriteRepository()
        sut = CheckFavoriteStatusUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests
    func test_execute_whenFavoriteExists_returnsTrue() {
        // Given
        let favoriteDTO = createFavoriteDTO(id: "test123")
        mockRepository.addFavorite(favoriteDTO)

        // When
        let result = sut.execute("test123")

        // Then
        XCTAssertTrue(result, "존재하는 찜의 경우 true를 반환해야 합니다.")
    }

    func test_execute_whenFavoriteDoesNotExist_returnsFalse() {
        // Given
        let performanceID = "nonexistent"

        // When
        let result = sut.execute(performanceID)

        // Then
        XCTAssertFalse(result, "존재하지 않는 찜의 경우 false를 반환해야 합니다.")
    }

    func test_execute_afterRemovingFavorite_returnsFalse() {
        // Given
        let favoriteDTO = createFavoriteDTO(id: "test456")
        mockRepository.addFavorite(favoriteDTO)
        try? mockRepository.removeFavorite(id: "test456")

        // When
        let result = sut.execute("test456")

        // Then
        XCTAssertFalse(result, "삭제된 찜의 경우 false를 반환해야 합니다.")
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

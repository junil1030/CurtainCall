//
//  ToggleFavoriteUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class ToggleFavoriteUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: ToggleFavoriteUseCase!
    private var mockRepository: MockFavoriteRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockFavoriteRepository()
        sut = ToggleFavoriteUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests - Add Favorite
    func test_execute_whenFavoriteDoesNotExist_addsAndReturnsTrue() {
        // Given
        let favoriteDTO = createFavoriteDTO(id: "test123")

        // When
        let result = sut.execute(favoriteDTO)

        // Then
        switch result {
        case .success(let isFavorite):
            XCTAssertTrue(isFavorite, "찜이 추가되면 true를 반환해야 합니다.")
            XCTAssertTrue(mockRepository.isFavorite(id: "test123"), "찜이 저장되어 있어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_whenAddingMultipleDifferentFavorites_allShouldBeAdded() {
        // Given
        let favoriteDTO1 = createFavoriteDTO(id: "test001")
        let favoriteDTO2 = createFavoriteDTO(id: "test002")

        // When
        let result1 = sut.execute(favoriteDTO1)
        let result2 = sut.execute(favoriteDTO2)

        // Then
        switch (result1, result2) {
        case (.success(let isFavorite1), .success(let isFavorite2)):
            XCTAssertTrue(isFavorite1, "첫 번째 찜이 추가되어야 합니다.")
            XCTAssertTrue(isFavorite2, "두 번째 찜이 추가되어야 합니다.")
            XCTAssertEqual(mockRepository.getFavoriteCount(), 2, "총 2개의 찜이 있어야 합니다.")
        default:
            XCTFail("모든 찜 추가가 성공해야 합니다.")
        }
    }

    // MARK: - Tests - Remove Favorite
    func test_execute_whenFavoriteExists_removesAndReturnsFalse() {
        // Given
        let favoriteDTO = createFavoriteDTO(id: "test456")
        mockRepository.addFavorite(favoriteDTO)

        // When
        let result = sut.execute(favoriteDTO)

        // Then
        switch result {
        case .success(let isFavorite):
            XCTAssertFalse(isFavorite, "찜이 제거되면 false를 반환해야 합니다.")
            XCTAssertFalse(mockRepository.isFavorite(id: "test456"), "찜이 삭제되어 있어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    // MARK: - Tests - Toggle Behavior
    func test_execute_whenToggledTwice_shouldReturnToOriginalState() {
        // Given
        let favoriteDTO = createFavoriteDTO(id: "test789")

        // When
        let result1 = sut.execute(favoriteDTO)  // Add
        let result2 = sut.execute(favoriteDTO)  // Remove

        // Then
        switch (result1, result2) {
        case (.success(let isFavorite1), .success(let isFavorite2)):
            XCTAssertTrue(isFavorite1, "첫 번째 토글에서 추가되어야 합니다.")
            XCTAssertFalse(isFavorite2, "두 번째 토글에서 제거되어야 합니다.")
            XCTAssertFalse(mockRepository.isFavorite(id: "test789"), "최종적으로 찜이 없어야 합니다.")
        default:
            XCTFail("모든 토글이 성공해야 합니다.")
        }
    }

    func test_execute_whenToggledMultipleTimes_shouldAlternate() {
        // Given
        let favoriteDTO = createFavoriteDTO(id: "test999")

        // When
        let result1 = sut.execute(favoriteDTO)  // Add
        let result2 = sut.execute(favoriteDTO)  // Remove
        let result3 = sut.execute(favoriteDTO)  // Add again

        // Then
        switch (result1, result2, result3) {
        case (.success(let isFavorite1), .success(let isFavorite2), .success(let isFavorite3)):
            XCTAssertTrue(isFavorite1, "첫 번째: 추가")
            XCTAssertFalse(isFavorite2, "두 번째: 제거")
            XCTAssertTrue(isFavorite3, "세 번째: 추가")
            XCTAssertTrue(mockRepository.isFavorite(id: "test999"), "최종적으로 찜이 있어야 합니다.")
        default:
            XCTFail("모든 토글이 성공해야 합니다.")
        }
    }

    // MARK: - Tests - Error Handling
    func test_execute_whenRepositoryThrowsError_returnsFailure() {
        // Given
        let favoriteDTO = createFavoriteDTO(id: "errorTest")
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NSError(domain: "TestError", code: 500, userInfo: nil)

        // When
        let result = sut.execute(favoriteDTO)

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

    func test_execute_afterError_canRecoverAndSucceed() {
        // Given
        let favoriteDTO = createFavoriteDTO(id: "recoverTest")
        mockRepository.shouldThrowError = true

        // When
        let failureResult = sut.execute(favoriteDTO)

        mockRepository.shouldThrowError = false
        let successResult = sut.execute(favoriteDTO)

        // Then
        switch (failureResult, successResult) {
        case (.failure, .success(let isFavorite)):
            XCTAssertTrue(isFavorite, "에러 복구 후 정상 동작해야 합니다.")
        default:
            XCTFail("첫 번째는 실패, 두 번째는 성공해야 합니다.")
        }
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

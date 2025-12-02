//
//  RemoveFavoriteUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class RemoveFavoriteUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: RemoveFavoriteUseCase!
    private var mockRepository: MockFavoriteRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockFavoriteRepository()
        sut = RemoveFavoriteUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests - Success Cases
    func test_execute_whenFavoriteExists_removesSuccessfully() {
        // Given
        let favoriteDTO = createFavoriteDTO(id: "test123")
        mockRepository.addFavorite(favoriteDTO)
        XCTAssertTrue(mockRepository.isFavorite(id: "test123"), "초기 상태: 찜이 존재해야 합니다.")

        // When
        let result = sut.execute("test123")

        // Then
        switch result {
        case .success:
            XCTAssertFalse(mockRepository.isFavorite(id: "test123"), "찜이 삭제되어야 합니다.")
            XCTAssertEqual(mockRepository.getFavoriteCount(), 0, "찜 개수는 0개여야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_whenRemovingFromMultipleFavorites_removesOnlyTargetFavorite() {
        // Given
        let favoriteDTO1 = createFavoriteDTO(id: "test001")
        let favoriteDTO2 = createFavoriteDTO(id: "test002")
        let favoriteDTO3 = createFavoriteDTO(id: "test003")
        mockRepository.addFavorite(favoriteDTO1)
        mockRepository.addFavorite(favoriteDTO2)
        mockRepository.addFavorite(favoriteDTO3)

        // When
        let result = sut.execute("test002")

        // Then
        switch result {
        case .success:
            XCTAssertTrue(mockRepository.isFavorite(id: "test001"), "test001은 유지되어야 합니다.")
            XCTAssertFalse(mockRepository.isFavorite(id: "test002"), "test002는 삭제되어야 합니다.")
            XCTAssertTrue(mockRepository.isFavorite(id: "test003"), "test003은 유지되어야 합니다.")
            XCTAssertEqual(mockRepository.getFavoriteCount(), 2, "찜 개수는 2개여야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_whenFavoriteDoesNotExist_succeeds() {
        // Given
        let performanceID = "nonexistent"
        XCTAssertFalse(mockRepository.isFavorite(id: performanceID), "찜이 존재하지 않아야 합니다.")

        // When
        let result = sut.execute(performanceID)

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getFavoriteCount(), 0, "찜 개수는 0개여야 합니다.")
        case .failure(let error):
            XCTFail("존재하지 않는 찜 삭제는 성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_removingAllFavorites_leavesEmptyRepository() {
        // Given
        let favoriteDTO1 = createFavoriteDTO(id: "test001")
        let favoriteDTO2 = createFavoriteDTO(id: "test002")
        mockRepository.addFavorite(favoriteDTO1)
        mockRepository.addFavorite(favoriteDTO2)

        // When
        let result1 = sut.execute("test001")
        let result2 = sut.execute("test002")

        // Then
        switch (result1, result2) {
        case (.success, .success):
            XCTAssertEqual(mockRepository.getFavoriteCount(), 0, "모든 찜이 삭제되어야 합니다.")
            XCTAssertTrue(mockRepository.getFavorites().isEmpty, "찜 목록이 비어있어야 합니다.")
        default:
            XCTFail("모든 삭제가 성공해야 합니다.")
        }
    }

    // MARK: - Tests - Idempotency
    func test_execute_removingSameFavoriteTwice_succeeds() {
        // Given
        let favoriteDTO = createFavoriteDTO(id: "test456")
        mockRepository.addFavorite(favoriteDTO)

        // When
        let result1 = sut.execute("test456")
        let result2 = sut.execute("test456")

        // Then
        switch (result1, result2) {
        case (.success, .success):
            XCTAssertFalse(mockRepository.isFavorite(id: "test456"), "찜이 삭제되어야 합니다.")
            XCTAssertEqual(mockRepository.getFavoriteCount(), 0, "찜 개수는 0개여야 합니다.")
        default:
            XCTFail("두 번 삭제해도 성공해야 합니다.")
        }
    }

    // MARK: - Tests - Error Handling
    func test_execute_whenRepositoryThrowsError_returnsFailure() {
        // Given
        let performanceID = "errorTest"
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NSError(domain: "TestError", code: 500, userInfo: nil)

        // When
        let result = sut.execute(performanceID)

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
        mockRepository.addFavorite(favoriteDTO)
        mockRepository.shouldThrowError = true

        // When
        let failureResult = sut.execute("recoverTest")

        mockRepository.shouldThrowError = false
        let successResult = sut.execute("recoverTest")

        // Then
        switch (failureResult, successResult) {
        case (.failure, .success):
            XCTAssertFalse(mockRepository.isFavorite(id: "recoverTest"), "에러 복구 후 삭제되어야 합니다.")
        default:
            XCTFail("첫 번째는 실패, 두 번째는 성공해야 합니다.")
        }
    }

    func test_execute_whenErrorOccurs_doesNotAffectOtherFavorites() {
        // Given
        let favoriteDTO1 = createFavoriteDTO(id: "test001")
        let favoriteDTO2 = createFavoriteDTO(id: "test002")
        mockRepository.addFavorite(favoriteDTO1)
        mockRepository.addFavorite(favoriteDTO2)
        mockRepository.shouldThrowError = true

        // When
        let result = sut.execute("test001")

        // Then
        switch result {
        case .success:
            XCTFail("에러가 발생해야 합니다.")
        case .failure:
            XCTAssertEqual(mockRepository.getFavoriteCount(), 2, "에러 발생 시 찜 개수가 변하지 않아야 합니다.")
            XCTAssertTrue(mockRepository.isFavorite(id: "test001"), "test001은 유지되어야 합니다.")
            XCTAssertTrue(mockRepository.isFavorite(id: "test002"), "test002는 유지되어야 합니다.")
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

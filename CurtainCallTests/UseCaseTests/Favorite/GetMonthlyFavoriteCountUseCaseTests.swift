//
//  GetMonthlyFavoriteCountUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class GetMonthlyFavoriteCountUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: GetMonthlyFavoriteCountUseCase!
    private var mockRepository: MockFavoriteRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockFavoriteRepository()
        sut = GetMonthlyFavoriteCountUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests
    func test_execute_whenNoFavorites_returnsZero() {
        // Given & When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result, 0, "찜이 없으면 0을 반환해야 합니다.")
    }

    func test_execute_whenFavoritesExistInCurrentMonth_returnsCorrectCount() {
        // Given
        let calendar = Calendar.current
        let now = Date()

        let thisMonthFavorite1 = createFavoriteDTO(id: "001", createdAt: now)
        let thisMonthFavorite2 = createFavoriteDTO(id: "002", createdAt: now.addingTimeInterval(-86400)) // 1일 전
        let thisMonthFavorite3 = createFavoriteDTO(id: "003", createdAt: now.addingTimeInterval(-172800)) // 2일 전

        mockRepository.addFavorite(thisMonthFavorite1)
        mockRepository.addFavorite(thisMonthFavorite2)
        mockRepository.addFavorite(thisMonthFavorite3)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result, 3, "이번 달 찜 개수는 3개여야 합니다.")
    }

    func test_execute_whenFavoritesExistInPreviousMonth_returnsZero() {
        // Given
        let calendar = Calendar.current
        let now = Date()

        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else {
            XCTFail("지난달 날짜 생성 실패")
            return
        }

        let lastMonthFavorite = createFavoriteDTO(id: "001", createdAt: lastMonth)
        mockRepository.addFavorite(lastMonthFavorite)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result, 0, "지난달 찜은 카운트되지 않아야 합니다.")
    }

    func test_execute_whenFavoritesExistInMixedMonths_returnsOnlyCurrentMonth() {
        // Given
        let calendar = Calendar.current
        let now = Date()

        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: now) else {
            XCTFail("테스트 날짜 생성 실패")
            return
        }

        let thisMonthFavorite1 = createFavoriteDTO(id: "001", createdAt: now)
        let thisMonthFavorite2 = createFavoriteDTO(id: "002", createdAt: now.addingTimeInterval(-86400))
        let lastMonthFavorite = createFavoriteDTO(id: "003", createdAt: lastMonth)
        let nextMonthFavorite = createFavoriteDTO(id: "004", createdAt: nextMonth)

        mockRepository.addFavorite(thisMonthFavorite1)
        mockRepository.addFavorite(thisMonthFavorite2)
        mockRepository.addFavorite(lastMonthFavorite)
        mockRepository.addFavorite(nextMonthFavorite)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result, 2, "이번 달 찜만 카운트되어야 합니다.")
    }

    func test_execute_whenFavoriteAtStartOfMonth_isIncluded() {
        // Given
        let calendar = Calendar.current
        let now = Date()

        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            XCTFail("이번 달 시작일 생성 실패")
            return
        }

        let favoriteAtStart = createFavoriteDTO(id: "001", createdAt: startOfMonth)
        mockRepository.addFavorite(favoriteAtStart)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result, 1, "이번 달 시작일의 찜은 포함되어야 합니다.")
    }

    func test_execute_whenFavoriteAtEndOfMonth_isIncluded() {
        // Given
        let calendar = Calendar.current
        let now = Date()

        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            XCTFail("이번 달 종료일 생성 실패")
            return
        }

        let favoriteAtEnd = createFavoriteDTO(id: "001", createdAt: endOfMonth)
        mockRepository.addFavorite(favoriteAtEnd)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result, 1, "이번 달 종료일의 찜은 포함되어야 합니다.")
    }

    // MARK: - Helper Methods
    private func createFavoriteDTO(
        id: String,
        title: String = "테스트 공연",
        genre: String? = GenreCode.musical.rawValue,
        area: String? = AreaCode.seoul.rawValue,
        createdAt: Date
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
            createdAt: createdAt,
            lastUpdated: Date()
        )
    }
}

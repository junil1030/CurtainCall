//
//  GetRecentSearchesUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class GetRecentSearchesUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: GetRecentSearchesUseCase!
    private var mockRepository: MockRecentSearchRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockRecentSearchRepository()
        sut = GetRecentSearchesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests
    func test_execute_whenNoSearches_returnsEmptyArray() {
        // Given & When
        let result = sut.execute(())

        // Then
        XCTAssertTrue(result.isEmpty, "검색 기록이 없으면 빈 배열을 반환해야 합니다.")
    }

    func test_execute_returnsRecentSearches() {
        // Given
        let search1 = RecentSearch(keyword: "뮤지컬", createdAt: Date().addingTimeInterval(-300))
        let search2 = RecentSearch(keyword: "연극", createdAt: Date().addingTimeInterval(-200))
        let search3 = RecentSearch(keyword: "콘서트", createdAt: Date().addingTimeInterval(-100))
        mockRepository.addSearchDirect(search1)
        mockRepository.addSearchDirect(search2)
        mockRepository.addSearchDirect(search3)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.count, 3, "3개의 검색 기록을 반환해야 합니다.")
        XCTAssertEqual(result[0].keyword, "콘서트", "가장 최근 검색어가 먼저 와야 합니다.")
        XCTAssertEqual(result[1].keyword, "연극")
        XCTAssertEqual(result[2].keyword, "뮤지컬")
    }

    func test_execute_limitsToMaxCount() {
        // Given
        for i in 1...10 {
            let search = RecentSearch(keyword: "검색\(i)", createdAt: Date().addingTimeInterval(Double(i)))
            mockRepository.addSearchDirect(search)
        }

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.count, 5, "최대 5개까지만 반환해야 합니다.")
    }

    func test_execute_returnsLatest5Searches() {
        // Given
        for i in 1...7 {
            let search = RecentSearch(
                keyword: "검색\(i)",
                createdAt: Date().addingTimeInterval(Double(i * 10))
            )
            mockRepository.addSearchDirect(search)
        }

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.count, 5, "5개를 반환해야 합니다.")
        XCTAssertEqual(result[0].keyword, "검색7", "가장 최근 검색어가 먼저 와야 합니다.")
        XCTAssertEqual(result[4].keyword, "검색3", "5번째는 검색3이어야 합니다.")
    }

    func test_execute_sortsByDateDescending() {
        // Given
        let search1 = RecentSearch(keyword: "첫번째", createdAt: Date().addingTimeInterval(-1000))
        let search2 = RecentSearch(keyword: "두번째", createdAt: Date().addingTimeInterval(-500))
        let search3 = RecentSearch(keyword: "세번째", createdAt: Date())
        mockRepository.addSearchDirect(search1)
        mockRepository.addSearchDirect(search2)
        mockRepository.addSearchDirect(search3)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result[0].keyword, "세번째", "최신순으로 정렬되어야 합니다.")
        XCTAssertEqual(result[1].keyword, "두번째")
        XCTAssertEqual(result[2].keyword, "첫번째")
    }
}

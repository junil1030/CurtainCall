//
//  ClearAllRecentSearchesUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class ClearAllRecentSearchesUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: ClearAllRecentSearchesUseCase!
    private var mockRepository: MockRecentSearchRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockRecentSearchRepository()
        sut = ClearAllRecentSearchesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests
    func test_execute_clearsAllSearches() {
        // Given
        let search1 = RecentSearch(keyword: "뮤지컬")
        let search2 = RecentSearch(keyword: "연극")
        let search3 = RecentSearch(keyword: "콘서트")
        mockRepository.addSearchDirect(search1)
        mockRepository.addSearchDirect(search2)
        mockRepository.addSearchDirect(search3)
        XCTAssertEqual(mockRepository.getSearchCount(), 3, "초기: 3개의 검색어가 있어야 합니다.")

        // When
        let result = sut.execute(())

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getSearchCount(), 0, "모든 검색어가 삭제되어야 합니다.")
            let searches = mockRepository.getRecentSearches(limit: 10)
            XCTAssertTrue(searches.isEmpty, "검색 기록이 비어있어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_whenNoSearches_succeeds() {
        // Given & When
        let result = sut.execute(())

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getSearchCount(), 0, "검색어 개수는 0이어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_afterClearing_canAddNewSearches() {
        // Given
        let search1 = RecentSearch(keyword: "뮤지컬")
        mockRepository.addSearchDirect(search1)
        _ = sut.execute(())

        // When
        try? mockRepository.addSearch("새로운검색어")

        // Then
        XCTAssertEqual(mockRepository.getSearchCount(), 1, "새로운 검색어가 추가되어야 합니다.")
        let searches = mockRepository.getRecentSearches(limit: 10)
        XCTAssertEqual(searches.first?.keyword, "새로운검색어", "새로운 검색어가 조회되어야 합니다.")
    }

    func test_execute_whenRepositoryThrowsError_returnsFailure() {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NSError(domain: "TestError", code: 500, userInfo: nil)

        // When
        let result = sut.execute(())

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
}

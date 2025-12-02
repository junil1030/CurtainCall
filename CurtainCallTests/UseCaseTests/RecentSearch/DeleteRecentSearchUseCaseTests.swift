//
//  DeleteRecentSearchUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class DeleteRecentSearchUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: DeleteRecentSearchUseCase!
    private var mockRepository: MockRecentSearchRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockRecentSearchRepository()
        sut = DeleteRecentSearchUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests
    func test_execute_deletesSearchSuccessfully() {
        // Given
        let search = RecentSearch(keyword: "뮤지컬")
        mockRepository.addSearchDirect(search)
        XCTAssertEqual(mockRepository.getSearchCount(), 1, "초기: 1개의 검색어가 있어야 합니다.")

        // When
        let result = sut.execute("뮤지컬")

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getSearchCount(), 0, "검색어가 삭제되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_deletesOnlySpecifiedSearch() {
        // Given
        let search1 = RecentSearch(keyword: "뮤지컬")
        let search2 = RecentSearch(keyword: "연극")
        let search3 = RecentSearch(keyword: "콘서트")
        mockRepository.addSearchDirect(search1)
        mockRepository.addSearchDirect(search2)
        mockRepository.addSearchDirect(search3)

        // When
        let result = sut.execute("연극")

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getSearchCount(), 2, "2개의 검색어가 남아야 합니다.")
            let searches = mockRepository.getRecentSearches(limit: 10)
            let keywords = searches.map { $0.keyword }
            XCTAssertTrue(keywords.contains("뮤지컬"), "뮤지컬은 유지되어야 합니다.")
            XCTAssertFalse(keywords.contains("연극"), "연극은 삭제되어야 합니다.")
            XCTAssertTrue(keywords.contains("콘서트"), "콘서트는 유지되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_whenKeywordNotFound_succeeds() {
        // Given
        let search = RecentSearch(keyword: "뮤지컬")
        mockRepository.addSearchDirect(search)

        // When
        let result = sut.execute("존재하지않는검색어")

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getSearchCount(), 1, "검색어 개수가 변하지 않아야 합니다.")
        case .failure(let error):
            XCTFail("존재하지 않는 검색어 삭제는 성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_whenRepositoryThrowsError_returnsFailure() {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NSError(domain: "TestError", code: 500, userInfo: nil)

        // When
        let result = sut.execute("뮤지컬")

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

//
//  AddRecentSearchUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class AddRecentSearchUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: AddRecentSearchUseCase!
    private var mockRepository: MockRecentSearchRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockRecentSearchRepository()
        sut = AddRecentSearchUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests
    func test_execute_addsSearchSuccessfully() {
        // Given
        let keyword = "뮤지컬"

        // When
        let result = sut.execute(keyword)

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getSearchCount(), 1, "검색어가 1개 추가되어야 합니다.")
            let searches = mockRepository.getRecentSearches(limit: 10)
            XCTAssertEqual(searches.first?.keyword, "뮤지컬", "검색어가 올바르게 저장되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_addsMultipleSearches() {
        // Given
        let keywords = ["뮤지컬", "연극", "콘서트"]

        // When
        for keyword in keywords {
            _ = sut.execute(keyword)
        }

        // Then
        XCTAssertEqual(mockRepository.getSearchCount(), 3, "3개의 검색어가 추가되어야 합니다.")
    }

    func test_execute_duplicateKeyword_updatesToLatest() {
        // Given
        let keyword = "뮤지컬"
        _ = sut.execute(keyword)
        Thread.sleep(forTimeInterval: 0.01)  // 시간 차이 확보

        // When
        _ = sut.execute(keyword)

        // Then
        let searches = mockRepository.getRecentSearches(limit: 10)
        XCTAssertEqual(mockRepository.getSearchCount(), 1, "중복 검색어는 1개만 유지되어야 합니다.")
        XCTAssertEqual(searches.first?.keyword, "뮤지컬", "검색어가 유지되어야 합니다.")
    }

    func test_execute_emptyKeyword_addsSuccessfully() {
        // Given
        let keyword = ""

        // When
        let result = sut.execute(keyword)

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getSearchCount(), 1, "빈 검색어도 추가되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_whenRepositoryThrowsError_returnsFailure() {
        // Given
        let keyword = "뮤지컬"
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NSError(domain: "TestError", code: 500, userInfo: nil)

        // When
        let result = sut.execute(keyword)

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

//
//  UpdateNicknameUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class UpdateNicknameUseCaseTests: XCTestCase {

    private var sut: UpdateNicknameUseCase!
    private var mockRepository: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        sut = UpdateNicknameUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_execute_withValidNickname_updatesSuccessfully() {
        // Given
        let nickname = "새로운닉네임"

        // When
        let result = sut.execute(nickname)

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getUserNickname(), "새로운닉네임", "닉네임이 업데이트되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_trimsWhitespace() {
        // Given
        let nickname = "  닉네임  "

        // When
        let result = sut.execute(nickname)

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getUserNickname(), "닉네임", "공백이 제거되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_withEmptyNickname_fails() {
        // Given
        let nickname = ""

        // When
        let result = sut.execute(nickname)

        // Then
        switch result {
        case .success:
            XCTFail("빈 닉네임은 실패해야 합니다.")
        case .failure(let error):
            XCTAssertTrue(error is NicknameValidationError, "유효성 검사 에러여야 합니다.")
        }
    }

    func test_execute_withWhitespaceOnly_fails() {
        // Given
        let nickname = "   "

        // When
        let result = sut.execute(nickname)

        // Then
        switch result {
        case .success:
            XCTFail("공백만 있는 닉네임은 실패해야 합니다.")
        case .failure(let error):
            XCTAssertTrue(error is NicknameValidationError, "유효성 검사 에러여야 합니다.")
        }
    }

    func test_execute_withTooLongNickname_fails() {
        // Given
        let nickname = "12345678901"  // 11자

        // When
        let result = sut.execute(nickname)

        // Then
        switch result {
        case .success:
            XCTFail("10자를 초과하는 닉네임은 실패해야 합니다.")
        case .failure(let error):
            XCTAssertTrue(error is NicknameValidationError, "유효성 검사 에러여야 합니다.")
        }
    }

    func test_execute_withExactly10Characters_succeeds() {
        // Given
        let nickname = "1234567890"  // 정확히 10자

        // When
        let result = sut.execute(nickname)

        // Then
        switch result {
        case .success:
            XCTAssertEqual(mockRepository.getUserNickname(), "1234567890", "10자 닉네임은 성공해야 합니다.")
        case .failure(let error):
            XCTFail("10자 닉네임은 성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_whenRepositoryThrowsError_returnsFailure() {
        // Given
        let nickname = "닉네임"
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NSError(domain: "TestError", code: 500, userInfo: nil)

        // When
        let result = sut.execute(nickname)

        // Then
        switch result {
        case .success:
            XCTFail("에러가 발생해야 합니다.")
        case .failure(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "TestError", "Repository 에러가 반환되어야 합니다.")
        }
    }
}

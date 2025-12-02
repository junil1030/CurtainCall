//
//  GetUserProfileUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class GetUserProfileUseCaseTests: XCTestCase {

    private var sut: GetUserProfileUseCase!
    private var mockRepository: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        sut = GetUserProfileUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_execute_whenUserExists_returnsUserProfile() {
        // Given
        let user = UserProfile(nickname: "테스트유저")
        mockRepository.setUser(user)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertNotNil(result, "사용자 프로필이 반환되어야 합니다.")
        XCTAssertEqual(result?.nickname, "테스트유저", "닉네임이 일치해야 합니다.")
    }

    func test_execute_whenNoUser_returnsNil() {
        // Given & When
        let result = sut.execute(())

        // Then
        XCTAssertNil(result, "사용자가 없으면 nil을 반환해야 합니다.")
    }
}

//
//  GetUserStatisticsUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class GetUserStatisticsUseCaseTests: XCTestCase {

    private var sut: GetUserStatisticsUseCase!
    private var mockUserRepository: MockUserRepository!
    private var mockViewingRecordRepository: MockViewingRecordRepository!
    private var mockFavoriteRepository: MockFavoriteRepository!

    override func setUp() {
        super.setUp()
        mockUserRepository = MockUserRepository()
        mockViewingRecordRepository = MockViewingRecordRepository()
        mockFavoriteRepository = MockFavoriteRepository()
        sut = GetUserStatisticsUseCase(
            userRepository: mockUserRepository,
            viewingRecordRepository: mockViewingRecordRepository,
            favoriteRepository: mockFavoriteRepository
        )
    }

    override func tearDown() {
        sut = nil
        mockUserRepository = nil
        mockViewingRecordRepository = nil
        mockFavoriteRepository = nil
        super.tearDown()
    }

    func test_execute_whenUserExists_returnsStatistics() {
        // Given
        let user = UserProfile(nickname: "테스트유저")
        user.createdAt = Date().addingTimeInterval(-86400 * 10)  // 10일 전 가입
        mockUserRepository.setUser(user)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.nickname, "테스트유저", "닉네임이 일치해야 합니다.")
        XCTAssertEqual(result.joinedDays, 10, "가입 일수가 계산되어야 합니다.")
    }

    func test_execute_whenNoUser_returnsDefaultStatistics() {
        // Given & When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.nickname, "닉네임", "기본 닉네임이 반환되어야 합니다.")
        XCTAssertEqual(result.joinedDays, 0, "가입 일수는 0이어야 합니다.")
        XCTAssertEqual(result.totalViewingCount, 0, "관람 기록은 0이어야 합니다.")
        XCTAssertEqual(result.totalFavoriteCount, 0, "찜 개수는 0이어야 합니다.")
    }

    func test_execute_includesViewingAndFavoriteCount() {
        // Given
        let user = UserProfile(nickname: "테스트유저")
        mockUserRepository.setUser(user)

        // ViewingRecord 3개 추가
        for i in 1...3 {
            let record = createViewingRecord(title: "공연\(i)")
            mockViewingRecordRepository.addRecordDirect(record)
        }

        // Favorite 2개 추가
        let favorite1 = createFavoriteDTO(id: "fav1")
        let favorite2 = createFavoriteDTO(id: "fav2")
        mockFavoriteRepository.addFavorite(favorite1)
        mockFavoriteRepository.addFavorite(favorite2)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.totalViewingCount, 3, "관람 기록 개수가 일치해야 합니다.")
        XCTAssertEqual(result.totalFavoriteCount, 2, "찜 개수가 일치해야 합니다.")
    }

    func test_execute_calculatesLevelCorrectly() {
        // Given
        let user = UserProfile(nickname: "테스트유저")
        mockUserRepository.setUser(user)

        // ViewingRecord 3개 추가 (3 * 10 = 30 exp)
        for i in 1...3 {
            let record = createViewingRecord(title: "공연\(i)")
            mockViewingRecordRepository.addRecordDirect(record)
        }

        // Favorite 5개 추가 (5 exp)
        for i in 1...5 {
            let favorite = createFavoriteDTO(id: "fav\(i)")
            mockFavoriteRepository.addFavorite(favorite)
        }

        // When
        let result = sut.execute(())

        // Then
        // Total exp = 30 + 5 = 35
        // Level = 35 / 30 = 1
        XCTAssertEqual(result.level, 1, "레벨이 올바르게 계산되어야 합니다.")
        XCTAssertEqual(result.currentExp, 5, "현재 경험치가 올바르게 계산되어야 합니다.")
        XCTAssertEqual(result.maxExp, 30, "최대 경험치는 30이어야 합니다.")
    }

    // MARK: - Helpers
    private func createViewingRecord(title: String) -> ViewingRecord {
        let record = ViewingRecord()
        record.performanceId = "perf001"
        record.title = title
        record.viewingDate = Date()
        record.createdAt = Date()
        record.updatedAt = Date()
        return record
    }

    private func createFavoriteDTO(id: String) -> FavoriteDTO {
        return FavoriteDTO(
            id: id,
            title: "테스트 공연",
            posterURL: nil,
            location: nil,
            startDate: nil,
            endDate: nil,
            area: nil,
            genre: nil,
            createdAt: Date(),
            lastUpdated: Date()
        )
    }
}

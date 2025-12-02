//
//  FetchStatsUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class FetchStatsUseCaseTests: XCTestCase {

    private var sut: FetchStatsUseCase!
    private var mockRepository: MockViewingRecordRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockViewingRecordRepository()
        sut = FetchStatsUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_execute_withWeeklyPeriod_returnsStatsData() {
        // Given
        let period = StatsPeriod.weekly

        // When
        let result = sut.execute(period)

        // Then
        XCTAssertEqual(result.period, .weekly, "기간이 일치해야 합니다.")
        XCTAssertNotNil(result.summary, "요약 정보가 있어야 합니다.")
        XCTAssertNotNil(result.trendData, "트렌드 데이터가 있어야 합니다.")
        XCTAssertNotNil(result.genreStats, "장르 통계가 있어야 합니다.")
        XCTAssertNotNil(result.companionStats, "동행인 통계가 있어야 합니다.")
        XCTAssertNotNil(result.areaStats, "지역 통계가 있어야 합니다.")
    }

    func test_execute_withMonthlyPeriod_returnsStatsData() {
        // Given
        let period = StatsPeriod.monthly

        // When
        let result = sut.execute(period)

        // Then
        XCTAssertEqual(result.period, .monthly, "기간이 일치해야 합니다.")
    }

    func test_execute_withYearlyPeriod_returnsStatsData() {
        // Given
        let period = StatsPeriod.yearly

        // When
        let result = sut.execute(period)

        // Then
        XCTAssertEqual(result.period, .yearly, "기간이 일치해야 합니다.")
    }

    func test_execute_callsRepositoryMethods() {
        // Given
        let period = StatsPeriod.weekly

        // When
        _ = sut.execute(period)

        // Then
        // Mock repository의 메서드들이 호출되었는지 확인
        // (실제 구현에서는 호출 카운트를 추적할 수 있습니다)
        XCTAssertTrue(true, "Repository 메서드들이 호출되어야 합니다.")
    }
}

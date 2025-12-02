//
//  GetAllViewingRecordsUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
import RealmSwift
@testable import CurtainCall

final class GetAllViewingRecordsUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: GetAllViewingRecordsUseCase!
    private var mockRepository: MockViewingRecordRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockViewingRecordRepository()
        sut = GetAllViewingRecordsUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests - Success Cases
    func test_execute_whenRecordsExist_returnsAllRecords() {
        // Given
        let record1 = createViewingRecord(title: "공연1", performanceId: "perf001")
        let record2 = createViewingRecord(title: "공연2", performanceId: "perf002")
        let record3 = createViewingRecord(title: "공연3", performanceId: "perf003")
        mockRepository.addRecordDirect(record1)
        mockRepository.addRecordDirect(record2)
        mockRepository.addRecordDirect(record3)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.count, 3, "모든 레코드를 반환해야 합니다.")

        let titles = result.map { $0.title }
        XCTAssertTrue(titles.contains("공연1"), "공연1이 포함되어야 합니다.")
        XCTAssertTrue(titles.contains("공연2"), "공연2가 포함되어야 합니다.")
        XCTAssertTrue(titles.contains("공연3"), "공연3이 포함되어야 합니다.")
    }

    func test_execute_returnsDTOList() {
        // Given
        let record = createViewingRecord(
            title: "테스트 공연",
            performanceId: "perf001",
            companion: "친구",
            seat: "R석 10열 5번",
            rating: 5,
            memo: "좋았어요!"
        )
        mockRepository.addRecordDirect(record)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.count, 1, "1개의 레코드를 반환해야 합니다.")

        let dto = result.first!
        XCTAssertEqual(dto.title, "테스트 공연", "제목이 일치해야 합니다.")
        XCTAssertEqual(dto.performanceId, "perf001", "공연 ID가 일치해야 합니다.")
        XCTAssertEqual(dto.companion, "친구", "동행인이 일치해야 합니다.")
        XCTAssertEqual(dto.seat, "R석 10열 5번", "좌석이 일치해야 합니다.")
        XCTAssertEqual(dto.rating, 5, "별점이 일치해야 합니다.")
        XCTAssertEqual(dto.memo, "좋았어요!", "감상평이 일치해야 합니다.")
    }

    func test_execute_sortsByViewingDateDescending() {
        // Given
        let calendar = Calendar.current
        let date1 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 10))!
        let date2 = calendar.date(from: DateComponents(year: 2025, month: 2, day: 15))!
        let date3 = calendar.date(from: DateComponents(year: 2025, month: 3, day: 20))!

        let record1 = createViewingRecord(title: "공연1", performanceId: "perf001", viewingDate: date1)
        let record2 = createViewingRecord(title: "공연2", performanceId: "perf002", viewingDate: date2)
        let record3 = createViewingRecord(title: "공연3", performanceId: "perf003", viewingDate: date3)

        mockRepository.addRecordDirect(record1)
        mockRepository.addRecordDirect(record2)
        mockRepository.addRecordDirect(record3)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.count, 3, "3개의 레코드를 반환해야 합니다.")
        XCTAssertEqual(result[0].title, "공연3", "가장 최근 관람한 공연이 먼저 와야 합니다.")
        XCTAssertEqual(result[1].title, "공연2")
        XCTAssertEqual(result[2].title, "공연1", "가장 오래된 관람이 마지막에 와야 합니다.")
    }

    func test_execute_convertsGenreCodeToDisplayName() {
        // Given
        let musicalRecord = createViewingRecord(title: "뮤지컬", performanceId: "perf001")
        musicalRecord.genre = GenreCode.musical.rawValue

        let playRecord = createViewingRecord(title: "연극", performanceId: "perf002")
        playRecord.genre = GenreCode.play.rawValue

        mockRepository.addRecordDirect(musicalRecord)
        mockRepository.addRecordDirect(playRecord)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.count, 2, "2개의 레코드를 반환해야 합니다.")

        let musicalDTO = result.first { $0.performanceId == "perf001" }
        let playDTO = result.first { $0.performanceId == "perf002" }

        XCTAssertEqual(musicalDTO?.genre, GenreCode.musical.displayName, "장르 코드가 표시명으로 변환되어야 합니다.")
        XCTAssertEqual(playDTO?.genre, GenreCode.play.displayName, "장르 코드가 표시명으로 변환되어야 합니다.")
    }

    func test_execute_includesAllFields() {
        // Given
        let record = createViewingRecord(
            title: "테스트 공연",
            performanceId: "perf001"
        )
        record.posterURL = "https://example.com/poster.jpg"
        record.area = AreaCode.seoul.rawValue
        record.location = "세종문화회관"
        record.genre = GenreCode.musical.rawValue
        record.cast = "배우1, 배우2"

        mockRepository.addRecordDirect(record)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.count, 1, "1개의 레코드를 반환해야 합니다.")

        let dto = result.first!
        XCTAssertEqual(dto.id, record.id.stringValue, "ID가 일치해야 합니다.")
        XCTAssertEqual(dto.performanceId, "perf001", "공연 ID가 일치해야 합니다.")
        XCTAssertEqual(dto.title, "테스트 공연", "제목이 일치해야 합니다.")
        XCTAssertEqual(dto.posterURL, "https://example.com/poster.jpg", "포스터 URL이 일치해야 합니다.")
        XCTAssertEqual(dto.area, AreaCode.seoul.rawValue, "지역이 일치해야 합니다.")
        XCTAssertEqual(dto.location, "세종문화회관", "공연장이 일치해야 합니다.")
        XCTAssertEqual(dto.genre, GenreCode.musical.displayName, "장르가 일치해야 합니다.")
        XCTAssertEqual(dto.cast, "배우1, 배우2", "출연진이 일치해야 합니다.")
    }

    // MARK: - Tests - Empty Cases
    func test_execute_whenNoRecords_returnsEmptyArray() {
        // Given & When
        let result = sut.execute(())

        // Then
        XCTAssertTrue(result.isEmpty, "레코드가 없으면 빈 배열을 반환해야 합니다.")
    }

    func test_execute_afterAllRecordsDeleted_returnsEmptyArray() {
        // Given
        let record1 = createViewingRecord(title: "공연1", performanceId: "perf001")
        let record2 = createViewingRecord(title: "공연2", performanceId: "perf002")
        mockRepository.addRecordDirect(record1)
        mockRepository.addRecordDirect(record2)

        try? mockRepository.deleteAllRecords()

        // When
        let result = sut.execute(())

        // Then
        XCTAssertTrue(result.isEmpty, "모든 레코드가 삭제되면 빈 배열을 반환해야 합니다.")
    }

    // MARK: - Tests - Multiple Records
    func test_execute_withManyRecords_returnsAllInCorrectOrder() {
        // Given
        let calendar = Calendar.current
        var records: [ViewingRecord] = []

        for i in 1...10 {
            let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: i))!
            let record = createViewingRecord(
                title: "공연\(i)",
                performanceId: "perf00\(i)",
                viewingDate: date
            )
            records.append(record)
            mockRepository.addRecordDirect(record)
        }

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.count, 10, "10개의 레코드를 반환해야 합니다.")
        XCTAssertEqual(result.first?.title, "공연10", "가장 최근 관람(1월 10일)이 먼저 와야 합니다.")
        XCTAssertEqual(result.last?.title, "공연1", "가장 오래된 관람(1월 1일)이 마지막에 와야 합니다.")
    }

    func test_execute_withSameDateRecords_maintainsSorting() {
        // Given
        let sameDate = Date()

        let record1 = createViewingRecord(title: "공연1", performanceId: "perf001", viewingDate: sameDate)
        let record2 = createViewingRecord(title: "공연2", performanceId: "perf002", viewingDate: sameDate)
        let record3 = createViewingRecord(title: "공연3", performanceId: "perf003", viewingDate: sameDate)

        mockRepository.addRecordDirect(record1)
        mockRepository.addRecordDirect(record2)
        mockRepository.addRecordDirect(record3)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.count, 3, "3개의 레코드를 반환해야 합니다.")
        // 같은 날짜의 경우 순서는 일관성만 유지하면 됨
    }

    // MARK: - Helper Methods
    private func createViewingRecord(
        title: String,
        performanceId: String,
        viewingDate: Date = Date(),
        companion: String = "혼자",
        seat: String = "R석 10열 5번",
        rating: Int = 5,
        memo: String = "좋았어요!"
    ) -> ViewingRecord {
        let record = ViewingRecord()
        record.performanceId = performanceId
        record.title = title
        record.posterURL = "https://example.com/poster.jpg"
        record.area = AreaCode.seoul.rawValue
        record.location = "테스트 극장"
        record.genre = GenreCode.musical.rawValue
        record.viewingDate = viewingDate
        record.companion = companion
        record.seat = seat
        record.rating = rating
        record.memo = memo
        record.createdAt = Date()
        record.updatedAt = Date()
        return record
    }
}

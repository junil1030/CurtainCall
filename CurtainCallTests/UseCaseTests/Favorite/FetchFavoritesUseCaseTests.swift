//
//  FetchFavoritesUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class FetchFavoritesUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: FetchFavoritesUseCase!
    private var mockRepository: MockFavoriteRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockFavoriteRepository()
        sut = FetchFavoritesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests - Default Filter
    func test_execute_withDefaultFilter_returnsAllFavoritesSortedByLatest() {
        // Given
        let favorite1 = createFavoriteDTO(id: "001", title: "공연A", createdAt: Date().addingTimeInterval(-1000))
        let favorite2 = createFavoriteDTO(id: "002", title: "공연B", createdAt: Date().addingTimeInterval(-500))
        let favorite3 = createFavoriteDTO(id: "003", title: "공연C", createdAt: Date())
        mockRepository.addFavorite(favorite1)
        mockRepository.addFavorite(favorite2)
        mockRepository.addFavorite(favorite3)

        let filterCondition = FavoriteFilterCondition.default

        // When
        let result = sut.execute(filterCondition)

        // Then
        XCTAssertEqual(result.count, 3, "모든 찜 목록을 반환해야 합니다.")
        XCTAssertEqual(result[0].id, "003", "가장 최근 찜이 먼저 와야 합니다.")
        XCTAssertEqual(result[1].id, "002")
        XCTAssertEqual(result[2].id, "001")
    }

    // MARK: - Tests - Genre Filter
    func test_execute_withGenreFilter_returnsFilteredByGenre() {
        // Given
        let musicalFavorite = createFavoriteDTO(id: "001", genre: GenreCode.musical.rawValue)
        let playFavorite = createFavoriteDTO(id: "002", genre: GenreCode.play.rawValue)
        let danceFavorite = createFavoriteDTO(id: "003", genre: GenreCode.dance.rawValue)
        mockRepository.addFavorite(musicalFavorite)
        mockRepository.addFavorite(playFavorite)
        mockRepository.addFavorite(danceFavorite)

        let filterCondition = FavoriteFilterCondition(genre: .musical)

        // When
        let result = sut.execute(filterCondition)

        // Then
        XCTAssertEqual(result.count, 1, "뮤지컬만 필터링되어야 합니다.")
        XCTAssertEqual(result[0].id, "001")
        XCTAssertEqual(result[0].genre, GenreCode.musical.rawValue)
    }

    // MARK: - Tests - Area Filter
    func test_execute_withAreaFilter_returnsFilteredByArea() {
        // Given
        let seoulFavorite = createFavoriteDTO(id: "001", area: AreaCode.seoul.rawValue)
        let busanFavorite = createFavoriteDTO(id: "002", area: AreaCode.busan.rawValue)
        let daeguFavorite = createFavoriteDTO(id: "003", area: AreaCode.daegu.rawValue)
        mockRepository.addFavorite(seoulFavorite)
        mockRepository.addFavorite(busanFavorite)
        mockRepository.addFavorite(daeguFavorite)

        let filterCondition = FavoriteFilterCondition(area: .seoul)

        // When
        let result = sut.execute(filterCondition)

        // Then
        XCTAssertEqual(result.count, 1, "서울 지역만 필터링되어야 합니다.")
        XCTAssertEqual(result[0].id, "001")
        XCTAssertEqual(result[0].area, AreaCode.seoul.rawValue)
    }

    // MARK: - Tests - Combined Filter
    func test_execute_withGenreAndAreaFilter_returnsFilteredByBoth() {
        // Given
        let favorite1 = createFavoriteDTO(id: "001", genre: GenreCode.musical.rawValue, area: AreaCode.seoul.rawValue)
        let favorite2 = createFavoriteDTO(id: "002", genre: GenreCode.musical.rawValue, area: AreaCode.busan.rawValue)
        let favorite3 = createFavoriteDTO(id: "003", genre: GenreCode.play.rawValue, area: AreaCode.seoul.rawValue)
        mockRepository.addFavorite(favorite1)
        mockRepository.addFavorite(favorite2)
        mockRepository.addFavorite(favorite3)

        let filterCondition = FavoriteFilterCondition(genre: .musical, area: .seoul)

        // When
        let result = sut.execute(filterCondition)

        // Then
        XCTAssertEqual(result.count, 1, "뮤지컬이면서 서울 지역만 필터링되어야 합니다.")
        XCTAssertEqual(result[0].id, "001")
    }

    // MARK: - Tests - Sort Type
    func test_execute_withLatestSort_returnsSortedByLatest() {
        // Given
        let favorite1 = createFavoriteDTO(id: "001", createdAt: Date().addingTimeInterval(-1000))
        let favorite2 = createFavoriteDTO(id: "002", createdAt: Date().addingTimeInterval(-500))
        let favorite3 = createFavoriteDTO(id: "003", createdAt: Date())
        mockRepository.addFavorite(favorite1)
        mockRepository.addFavorite(favorite2)
        mockRepository.addFavorite(favorite3)

        let filterCondition = FavoriteFilterCondition(sortType: .latest)

        // When
        let result = sut.execute(filterCondition)

        // Then
        XCTAssertEqual(result[0].id, "003", "최신순 정렬: 가장 최근 찜이 먼저")
        XCTAssertEqual(result[1].id, "002")
        XCTAssertEqual(result[2].id, "001")
    }

    func test_execute_withOldestSort_returnsSortedByOldest() {
        // Given
        let favorite1 = createFavoriteDTO(id: "001", createdAt: Date().addingTimeInterval(-1000))
        let favorite2 = createFavoriteDTO(id: "002", createdAt: Date().addingTimeInterval(-500))
        let favorite3 = createFavoriteDTO(id: "003", createdAt: Date())
        mockRepository.addFavorite(favorite1)
        mockRepository.addFavorite(favorite2)
        mockRepository.addFavorite(favorite3)

        let filterCondition = FavoriteFilterCondition(sortType: .oldest)

        // When
        let result = sut.execute(filterCondition)

        // Then
        XCTAssertEqual(result[0].id, "001", "오래된순 정렬: 가장 오래된 찜이 먼저")
        XCTAssertEqual(result[1].id, "002")
        XCTAssertEqual(result[2].id, "003")
    }

    func test_execute_withNameAscendingSort_returnsSortedByNameAscending() {
        // Given
        let favorite1 = createFavoriteDTO(id: "001", title: "C공연")
        let favorite2 = createFavoriteDTO(id: "002", title: "A공연")
        let favorite3 = createFavoriteDTO(id: "003", title: "B공연")
        mockRepository.addFavorite(favorite1)
        mockRepository.addFavorite(favorite2)
        mockRepository.addFavorite(favorite3)

        let filterCondition = FavoriteFilterCondition(sortType: .nameAscending)

        // When
        let result = sut.execute(filterCondition)

        // Then
        XCTAssertEqual(result[0].title, "A공연", "이름 오름차순 정렬")
        XCTAssertEqual(result[1].title, "B공연")
        XCTAssertEqual(result[2].title, "C공연")
    }

    func test_execute_withNameDescendingSort_returnsSortedByNameDescending() {
        // Given
        let favorite1 = createFavoriteDTO(id: "001", title: "C공연")
        let favorite2 = createFavoriteDTO(id: "002", title: "A공연")
        let favorite3 = createFavoriteDTO(id: "003", title: "B공연")
        mockRepository.addFavorite(favorite1)
        mockRepository.addFavorite(favorite2)
        mockRepository.addFavorite(favorite3)

        let filterCondition = FavoriteFilterCondition(sortType: .nameDescending)

        // When
        let result = sut.execute(filterCondition)

        // Then
        XCTAssertEqual(result[0].title, "C공연", "이름 내림차순 정렬")
        XCTAssertEqual(result[1].title, "B공연")
        XCTAssertEqual(result[2].title, "A공연")
    }

    // MARK: - Tests - Empty Results
    func test_execute_whenNoFavorites_returnsEmptyArray() {
        // Given
        let filterCondition = FavoriteFilterCondition.default

        // When
        let result = sut.execute(filterCondition)

        // Then
        XCTAssertTrue(result.isEmpty, "찜 목록이 없으면 빈 배열을 반환해야 합니다.")
    }

    func test_execute_whenFilterMatchesNothing_returnsEmptyArray() {
        // Given
        let favorite = createFavoriteDTO(id: "001", genre: GenreCode.musical.rawValue)
        mockRepository.addFavorite(favorite)

        let filterCondition = FavoriteFilterCondition(genre: .play)

        // When
        let result = sut.execute(filterCondition)

        // Then
        XCTAssertTrue(result.isEmpty, "필터 조건에 맞는 찜이 없으면 빈 배열을 반환해야 합니다.")
    }

    // MARK: - Helper Methods
    private func createFavoriteDTO(
        id: String,
        title: String = "테스트 공연",
        genre: String? = GenreCode.musical.rawValue,
        area: String? = AreaCode.seoul.rawValue,
        createdAt: Date = Date()
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

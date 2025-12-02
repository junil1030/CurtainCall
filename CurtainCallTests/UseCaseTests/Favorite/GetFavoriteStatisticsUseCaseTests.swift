//
//  GetFavoriteStatisticsUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
@testable import CurtainCall

final class GetFavoriteStatisticsUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: GetFavoriteStatisticsUseCase!
    private var mockRepository: MockFavoriteRepository!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockFavoriteRepository()
        sut = GetFavoriteStatisticsUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests
    func test_execute_whenNoFavorites_returnsZeroStatistics() {
        // Given & When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.totalCount, 0, "찜이 없으면 총 개수는 0이어야 합니다.")
        XCTAssertTrue(result.genreCount.isEmpty, "찜이 없으면 장르별 통계는 비어있어야 합니다.")
        XCTAssertTrue(result.areaCount.isEmpty, "찜이 없으면 지역별 통계는 비어있어야 합니다.")
    }

    func test_execute_withMultipleFavorites_returnsCorrectTotalCount() {
        // Given
        let favorite1 = createFavoriteDTO(id: "001")
        let favorite2 = createFavoriteDTO(id: "002")
        let favorite3 = createFavoriteDTO(id: "003")
        mockRepository.addFavorite(favorite1)
        mockRepository.addFavorite(favorite2)
        mockRepository.addFavorite(favorite3)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.totalCount, 3, "총 찜 개수는 3개여야 합니다.")
    }

    func test_execute_withMultipleGenres_returnsCorrectGenreCount() {
        // Given
        let musicalFavorite1 = createFavoriteDTO(id: "001", genre: GenreCode.musical.rawValue)
        let musicalFavorite2 = createFavoriteDTO(id: "002", genre: GenreCode.musical.rawValue)
        let playFavorite = createFavoriteDTO(id: "003", genre: GenreCode.play.rawValue)
        let danceFavorite = createFavoriteDTO(id: "004", genre: GenreCode.dance.rawValue)
        mockRepository.addFavorite(musicalFavorite1)
        mockRepository.addFavorite(musicalFavorite2)
        mockRepository.addFavorite(playFavorite)
        mockRepository.addFavorite(danceFavorite)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.genreCount[GenreCode.musical.displayName], 2, "뮤지컬 장르는 2개여야 합니다.")
        XCTAssertEqual(result.genreCount[GenreCode.play.displayName], 1, "연극 장르는 1개여야 합니다.")
        XCTAssertEqual(result.genreCount[GenreCode.dance.displayName], 1, "무용 장르는 1개여야 합니다.")
    }

    func test_execute_withMultipleAreas_returnsCorrectAreaCount() {
        // Given
        let seoulFavorite1 = createFavoriteDTO(id: "001", area: AreaCode.seoul.rawValue)
        let seoulFavorite2 = createFavoriteDTO(id: "002", area: AreaCode.seoul.rawValue)
        let seoulFavorite3 = createFavoriteDTO(id: "003", area: AreaCode.seoul.rawValue)
        let busanFavorite = createFavoriteDTO(id: "004", area: AreaCode.busan.rawValue)
        mockRepository.addFavorite(seoulFavorite1)
        mockRepository.addFavorite(seoulFavorite2)
        mockRepository.addFavorite(seoulFavorite3)
        mockRepository.addFavorite(busanFavorite)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.areaCount[AreaCode.seoul.displayName], 3, "서울 지역은 3개여야 합니다.")
        XCTAssertEqual(result.areaCount[AreaCode.busan.displayName], 1, "부산 지역은 1개여야 합니다.")
    }

    func test_execute_mostFavoriteGenre_returnsCorrectGenre() {
        // Given
        let musicalFavorite1 = createFavoriteDTO(id: "001", genre: GenreCode.musical.rawValue)
        let musicalFavorite2 = createFavoriteDTO(id: "002", genre: GenreCode.musical.rawValue)
        let playFavorite = createFavoriteDTO(id: "003", genre: GenreCode.play.rawValue)
        mockRepository.addFavorite(musicalFavorite1)
        mockRepository.addFavorite(musicalFavorite2)
        mockRepository.addFavorite(playFavorite)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.mostFavoriteGenre, GenreCode.musical.displayName, "가장 많은 장르는 뮤지컬이어야 합니다.")
    }

    func test_execute_mostFavoriteArea_returnsCorrectArea() {
        // Given
        let seoulFavorite1 = createFavoriteDTO(id: "001", area: AreaCode.seoul.rawValue)
        let seoulFavorite2 = createFavoriteDTO(id: "002", area: AreaCode.seoul.rawValue)
        let seoulFavorite3 = createFavoriteDTO(id: "003", area: AreaCode.seoul.rawValue)
        let busanFavorite = createFavoriteDTO(id: "004", area: AreaCode.busan.rawValue)
        mockRepository.addFavorite(seoulFavorite1)
        mockRepository.addFavorite(seoulFavorite2)
        mockRepository.addFavorite(seoulFavorite3)
        mockRepository.addFavorite(busanFavorite)

        // When
        let result = sut.execute(())

        // Then
        XCTAssertEqual(result.mostFavoriteArea, AreaCode.seoul.displayName, "가장 많은 지역은 서울이어야 합니다.")
    }

    func test_execute_sortedGenreCount_returnsSortedByCountDescending() {
        // Given
        let musicalFavorite1 = createFavoriteDTO(id: "001", genre: GenreCode.musical.rawValue)
        let musicalFavorite2 = createFavoriteDTO(id: "002", genre: GenreCode.musical.rawValue)
        let musicalFavorite3 = createFavoriteDTO(id: "003", genre: GenreCode.musical.rawValue)
        let playFavorite1 = createFavoriteDTO(id: "004", genre: GenreCode.play.rawValue)
        let playFavorite2 = createFavoriteDTO(id: "005", genre: GenreCode.play.rawValue)
        let danceFavorite = createFavoriteDTO(id: "006", genre: GenreCode.dance.rawValue)
        mockRepository.addFavorite(musicalFavorite1)
        mockRepository.addFavorite(musicalFavorite2)
        mockRepository.addFavorite(musicalFavorite3)
        mockRepository.addFavorite(playFavorite1)
        mockRepository.addFavorite(playFavorite2)
        mockRepository.addFavorite(danceFavorite)

        // When
        let result = sut.execute(())
        let sortedGenres = result.sortedGenreCount

        // Then
        XCTAssertEqual(sortedGenres.count, 3, "장르는 3개여야 합니다.")
        XCTAssertEqual(sortedGenres[0].genre, GenreCode.musical.displayName, "첫 번째는 뮤지컬이어야 합니다.")
        XCTAssertEqual(sortedGenres[0].count, 3)
        XCTAssertEqual(sortedGenres[1].genre, GenreCode.play.displayName, "두 번째는 연극이어야 합니다.")
        XCTAssertEqual(sortedGenres[1].count, 2)
        XCTAssertEqual(sortedGenres[2].genre, GenreCode.dance.displayName, "세 번째는 무용이어야 합니다.")
        XCTAssertEqual(sortedGenres[2].count, 1)
    }

    func test_execute_sortedAreaCount_returnsSortedByCountDescending() {
        // Given
        let seoulFavorite1 = createFavoriteDTO(id: "001", area: AreaCode.seoul.rawValue)
        let seoulFavorite2 = createFavoriteDTO(id: "002", area: AreaCode.seoul.rawValue)
        let busanFavorite = createFavoriteDTO(id: "003", area: AreaCode.busan.rawValue)
        mockRepository.addFavorite(seoulFavorite1)
        mockRepository.addFavorite(seoulFavorite2)
        mockRepository.addFavorite(busanFavorite)

        // When
        let result = sut.execute(())
        let sortedAreas = result.sortedAreaCount

        // Then
        XCTAssertEqual(sortedAreas.count, 2, "지역은 2개여야 합니다.")
        XCTAssertEqual(sortedAreas[0].area, AreaCode.seoul.displayName, "첫 번째는 서울이어야 합니다.")
        XCTAssertEqual(sortedAreas[0].count, 2)
        XCTAssertEqual(sortedAreas[1].area, AreaCode.busan.displayName, "두 번째는 부산이어야 합니다.")
        XCTAssertEqual(sortedAreas[1].count, 1)
    }

    // MARK: - Helper Methods
    private func createFavoriteDTO(
        id: String,
        title: String = "테스트 공연",
        genre: String? = GenreCode.musical.rawValue,
        area: String? = AreaCode.seoul.rawValue
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
            createdAt: Date(),
            lastUpdated: Date()
        )
    }
}

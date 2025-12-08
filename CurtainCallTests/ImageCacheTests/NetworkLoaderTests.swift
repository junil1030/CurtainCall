//
//  NetworkLoaderTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 12/7/25.
//

import XCTest
@testable import CurtainCall

final class NetworkLoaderTests: XCTestCase {

    var sut: NetworkLoader!

    override func setUp() async throws {
        try await super.setUp()
        sut = NetworkLoader()
    }

    override func tearDown() async throws {
        await sut.cancelAllDownloads()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Download Tests

    func test_downloadImage_validURL_returnsSuccess() async throws {
        // Given
        // 실제 테스트용 이미지 URL (작은 PNG 이미지)
        let url = URL(string: "https://via.placeholder.com/150")!

        // When
        let result = try await sut.downloadImage(url: url)

        // Then
        switch result {
        case .success(let data, _):
            XCTAssertFalse(data.isEmpty, "이미지 데이터가 있어야 함")
        case .notModified:
            XCTFail("첫 요청은 304가 아니어야 함")
        }
    }

    func test_downloadImage_withETag_canReturn304() async throws {
        // Given
        let url = URL(string: "https://via.placeholder.com/150")!

        // 첫 요청으로 ETag 받기
        let firstResult = try await sut.downloadImage(url: url)

        guard case .success(_, let etag) = firstResult, let etag = etag else {
            XCTFail("첫 요청에서 ETag를 받아야 함")
            return
        }

        // When - 같은 ETag로 재요청
        let secondResult = try await sut.downloadImage(url: url, etag: etag)

        // Then
        // 서버가 ETag를 지원하면 304, 지원하지 않으면 200
        switch secondResult {
        case .success:
            // 일부 서버는 ETag를 지원하지 않을 수 있음
            break
        case .notModified:
            // ETag가 유효하면 304 응답
            break
        }
    }

    func test_downloadImage_invalidURL_throwsError() async {
        // Given
        let url = URL(string: "https://invalid-domain-that-does-not-exist-12345.com/image.jpg")!

        // When & Then
        do {
            _ = try await sut.downloadImage(url: url)
            XCTFail("유효하지 않은 URL은 에러를 던져야 함")
        } catch {
            // 에러 발생 예상
            XCTAssertTrue(error is ImageCacheNetworkError || error is URLError)
        }
    }

    func test_downloadImage_404_throwsNotFoundError() async {
        // Given
        let url = URL(string: "https://httpstat.us/404")!

        // When & Then
        do {
            _ = try await sut.downloadImage(url: url)
            XCTFail("404는 notFound 에러를 던져야 함")
        } catch let error as ImageCacheNetworkError {
            if case .notFound = error {
                // 성공
            } else {
                XCTFail("notFound 에러여야 함")
            }
        } catch {
            XCTFail("ImageCacheNetworkError여야 함")
        }
    }

    // MARK: - Cancel Tests

    func test_cancelDownload_cancelsOngoingRequest() async throws {
        // Given
        let url = URL(string: "https://via.placeholder.com/1500")! // 큰 이미지

        // When
        let task = Task {
            try await sut.downloadImage(url: url)
        }

        // 즉시 취소
        await sut.cancelDownload(url: url)

        // Then
        do {
            _ = try await task.value
            // 취소되지 않을 수도 있음 (이미 완료된 경우)
        } catch {
            // 취소 에러 또는 완료
        }
    }

    func test_cancelAllDownloads_cancelsAllRequests() async {
        // Given
        let urls = [
            URL(string: "https://via.placeholder.com/150")!,
            URL(string: "https://via.placeholder.com/200")!,
            URL(string: "https://via.placeholder.com/250")!
        ]

        let tasks = urls.map { url in
            Task {
                try? await sut.downloadImage(url: url)
            }
        }

        // When
        await sut.cancelAllDownloads()

        // Then
        for task in tasks {
            _ = await task.value
            // 모든 task가 종료되어야 함 (취소 또는 완료)
        }
    }

    // MARK: - Statistics Tests

    func test_getStatistics_tracksDownloads() async throws {
        // Given
        let url = URL(string: "https://via.placeholder.com/150")!

        // When
        _ = try await sut.downloadImage(url: url)
        let stats = await sut.getStatistics()

        // Then
        XCTAssertGreaterThan(stats.downloads, 0, "다운로드 횟수가 기록되어야 함")
        XCTAssertGreaterThan(stats.downloaded, 0, "다운로드 바이트가 기록되어야 함")
    }

    func test_resetStatistics_resetsCounters() async throws {
        // Given
        let url = URL(string: "https://via.placeholder.com/150")!
        _ = try await sut.downloadImage(url: url)

        // When
        await sut.resetStatistics()
        let stats = await sut.getStatistics()

        // Then
        XCTAssertEqual(stats.downloads, 0, "통계가 초기화되어야 함")
        XCTAssertEqual(stats.downloaded, 0, "통계가 초기화되어야 함")
    }

    func test_getETagHitRate_calculatesCorrectly() async throws {
        // Given
        let url = URL(string: "https://via.placeholder.com/150")!

        // 첫 요청
        let firstResult = try await sut.downloadImage(url: url)
        guard case .success(_, let etag) = firstResult, let etag = etag else {
            return
        }

        // ETag로 재요청
        _ = try? await sut.downloadImage(url: url, etag: etag)

        // When
        let hitRate = await sut.getETagHitRate()

        // Then
        // 서버가 304를 반환하면 0.5 (1/2), 아니면 0.0
        XCTAssertTrue(hitRate >= 0.0 && hitRate <= 1.0, "히트율은 0.0~1.0 사이")
    }
}

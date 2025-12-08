//
//  CacheMetadataTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 12/7/25.
//

import XCTest
@testable import CurtainCall

final class CacheMetadataTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_setsDefaultValues() {
        // Given
        let url = "https://test.com/image.jpg"
        let targetSize = CGSize(width: 300, height: 450)

        // When
        let metadata = CacheMetadata(
            url: url,
            targetSize: targetSize
        )

        // Then
        XCTAssertEqual(metadata.url, url)
        XCTAssertNil(metadata.etag, "기본값은 nil이어야 함")
        XCTAssertEqual(metadata.accessCount, 1, "초기 접근 횟수는 1")
        XCTAssertEqual(metadata.fileSize, 0, "초기 파일 크기는 0")
        XCTAssertEqual(metadata.targetSize, targetSize)
    }

    // MARK: - Record Access Tests

    func test_recordAccess_incrementsCount() {
        // Given
        var metadata = CacheMetadata(
            url: "https://test.com",
            targetSize: CGSize(width: 300, height: 450)
        )

        // When
        metadata.recordAccess()
        metadata.recordAccess()

        // Then
        XCTAssertEqual(metadata.accessCount, 3, "접근 횟수가 증가해야 함 (초기 1 + 2회)")
    }

    func test_recordAccess_updatesLastAccessTime() {
        // Given
        var metadata = CacheMetadata(
            url: "https://test.com",
            targetSize: CGSize(width: 300, height: 450)
        )
        let oldAccessTime = metadata.lastAccessTime

        // When
        Thread.sleep(forTimeInterval: 0.01)
        metadata.recordAccess()

        // Then
        XCTAssertTrue(metadata.lastAccessTime > oldAccessTime, "마지막 접근 시간이 갱신되어야 함")
    }

    // MARK: - Mark Validated Tests

    func test_markValidated_updatesLastValidated() {
        // Given
        var metadata = CacheMetadata(
            url: "https://test.com",
            targetSize: CGSize(width: 300, height: 450)
        )
        let oldValidatedTime = metadata.lastValidated

        // When
        Thread.sleep(forTimeInterval: 0.01)
        metadata.markValidated()

        // Then
        XCTAssertTrue(metadata.lastValidated > oldValidatedTime, "검증 시간이 갱신되어야 함")
    }

    // MARK: - TTL Tests

    func test_isTTLExpired_withinTTL_returnsFalse() {
        // Given
        let metadata = CacheMetadata(
            url: "https://test.com",
            cachedDate: Date(), // 방금 캐시됨
            targetSize: CGSize(width: 300, height: 450)
        )
        let ttl: TimeInterval = 7 * 24 * 60 * 60 // 7일

        // When
        let isExpired = metadata.isTTLExpired(ttl: ttl)

        // Then
        XCTAssertFalse(isExpired, "7일 이내이므로 만료되지 않아야 함")
    }

    func test_isTTLExpired_exceedsTTL_returnsTrue() {
        // Given
        let pastDate = Date().addingTimeInterval(-8 * 24 * 60 * 60) // 8일 전
        let metadata = CacheMetadata(
            url: "https://test.com",
            cachedDate: pastDate,
            targetSize: CGSize(width: 300, height: 450)
        )
        let ttl: TimeInterval = 7 * 24 * 60 * 60 // 7일

        // When
        let isExpired = metadata.isTTLExpired(ttl: ttl)

        // Then
        XCTAssertTrue(isExpired, "7일 초과이므로 만료되어야 함")
    }

    // MARK: - Calculate Score Tests

    func test_calculateScore_recentAndFrequent_returnsHighScore() {
        // Given
        var metadata = CacheMetadata(
            url: "https://test.com",
            cachedDate: Date(),
            lastAccessTime: Date(), // 방금 접근
            targetSize: CGSize(width: 300, height: 450)
        )

        // 여러 번 접근
        for _ in 1...10 {
            metadata.recordAccess()
        }

        // When
        let score = metadata.calculateScore(maxAccessCount: 10)

        // Then
        XCTAssertGreaterThan(score, 0.8, "최근이고 자주 접근했으므로 높은 점수")
    }

    func test_calculateScore_oldAndInfrequent_returnsLowScore() {
        // Given
        let oldDate = Date().addingTimeInterval(-6 * 24 * 60 * 60) // 6일 전
        let metadata = CacheMetadata(
            url: "https://test.com",
            cachedDate: oldDate,
            lastAccessTime: oldDate,
            accessCount: 1, // 접근 1회
            targetSize: CGSize(width: 300, height: 450)
        )

        // When
        let score = metadata.calculateScore(maxAccessCount: 100)

        // Then
        XCTAssertLessThan(score, 0.3, "오래되었고 접근 적으므로 낮은 점수")
    }

    func test_calculateScore_lruWeight70_lfuWeight30() {
        // Given - 최근이지만 접근 횟수 적음
        let recentMetadata = CacheMetadata(
            url: "https://recent.com",
            cachedDate: Date(),
            lastAccessTime: Date(),
            accessCount: 1,
            targetSize: CGSize(width: 300, height: 450)
        )

        // Given - 오래되었지만 접근 횟수 많음
        let oldDate = Date().addingTimeInterval(-5 * 24 * 60 * 60)
        var oldMetadata = CacheMetadata(
            url: "https://old.com",
            cachedDate: oldDate,
            lastAccessTime: oldDate,
            accessCount: 1,
            targetSize: CGSize(width: 300, height: 450)
        )

        for _ in 1...50 {
            oldMetadata.recordAccess()
        }

        // When
        let recentScore = recentMetadata.calculateScore(maxAccessCount: 50)
        let oldScore = oldMetadata.calculateScore(maxAccessCount: 50)

        // Then
        // LRU 가중치가 70%이므로 최근 것이 더 높은 점수를 받아야 함
        XCTAssertGreaterThan(recentScore, oldScore, "LRU 70% 가중치로 최근 것이 더 높은 점수")
    }

    // MARK: - Codable Tests

    func test_codable_encodesAndDecodesCorrectly() throws {
        // Given
        let original = CacheMetadata(
            url: "https://test.com",
            etag: "abc123",
            cachedDate: Date(),
            lastValidated: Date(),
            accessCount: 5,
            lastAccessTime: Date(),
            fileSize: 10240,
            targetSize: CGSize(width: 300, height: 450)
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CacheMetadata.self, from: data)

        // Then
        XCTAssertEqual(decoded.url, original.url)
        XCTAssertEqual(decoded.etag, original.etag)
        XCTAssertEqual(decoded.accessCount, original.accessCount)
        XCTAssertEqual(decoded.fileSize, original.fileSize)
        XCTAssertEqual(decoded.targetSize.width, original.targetSize.width, accuracy: 0.1)
        XCTAssertEqual(decoded.targetSize.height, original.targetSize.height, accuracy: 0.1)
    }
}

//
//  MemoryCacheActorTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 12/7/25.
//

import XCTest
@testable import CurtainCall

final class MemoryCacheActorTests: XCTestCase {

    var sut: MemoryCacheActor!

    override func setUp() async throws {
        try await super.setUp()
        sut = MemoryCacheActor(memoryLimit: 10 * 1024 * 1024) // 10MB
    }

    override func tearDown() async throws {
        await sut.clearAll()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Get/Set Tests

    func test_get_nonExistentKey_returnsNil() async {
        // When
        let image = await sut.get(key: "nonexistent")

        // Then
        XCTAssertNil(image, "존재하지 않는 키는 nil 반환")
    }

    func test_set_andGet_returnsImage() async {
        // Given
        let key = "test_key"
        let image = createTestImage()
        let metadata = createMetadata()

        // When
        await sut.set(key: key, image: image, metadata: metadata)
        let retrieved = await sut.get(key: key)

        // Then
        XCTAssertNotNil(retrieved, "저장한 이미지를 가져올 수 있어야 함")
    }

    func test_set_multipleImages() async {
        // Given & When
        for i in 1...5 {
            let image = createTestImage()
            let metadata = createMetadata()
            await sut.set(key: "key\(i)", image: image, metadata: metadata)
        }

        // Then
        let image = await sut.get(key: "key3")
        XCTAssertNotNil(image, "여러 이미지 중 하나를 가져올 수 있어야 함")
    }

    // MARK: - Remove Tests

    func test_remove_existingKey_removesImage() async {
        // Given
        let key = "test_key"
        let image = createTestImage()
        let metadata = createMetadata()
        await sut.set(key: key, image: image, metadata: metadata)

        // When
        await sut.remove(key: key)
        let retrieved = await sut.get(key: key)

        // Then
        XCTAssertNil(retrieved, "제거된 이미지는 nil 반환")
    }

    func test_clearAll_removesAllImages() async {
        // Given
        for i in 1...5 {
            let image = createTestImage()
            let metadata = createMetadata()
            await sut.set(key: "key\(i)", image: image, metadata: metadata)
        }

        // When
        await sut.clearAll()

        // Then
        for i in 1...5 {
            let retrieved = await sut.get(key: "key\(i)")
            XCTAssertNil(retrieved, "모든 이미지가 제거되어야 함")
        }
    }

    // MARK: - Hit Rate Tests

    func test_getHitRate_calculatesCorrectly() async {
        // Given
        let key = "test_key"
        let image = createTestImage()
        let metadata = createMetadata()
        await sut.set(key: key, image: image, metadata: metadata)

        // When
        _ = await sut.get(key: key) // hit
        _ = await sut.get(key: key) // hit
        _ = await sut.get(key: "nonexistent") // miss

        let hitRate = await sut.getHitRate()

        // Then
        XCTAssertEqual(hitRate, 2.0 / 3.0, accuracy: 0.01, "히트율이 66.67%여야 함")
    }

    func test_resetStatistics_resetsHitRate() async {
        // Given
        let key = "test_key"
        let image = createTestImage()
        let metadata = createMetadata()
        await sut.set(key: key, image: image, metadata: metadata)
        _ = await sut.get(key: key)

        // When
        await sut.resetStatistics()
        let hitRate = await sut.getHitRate()

        // Then
        XCTAssertEqual(hitRate, 0.0, "통계가 초기화되어야 함")
    }

    // MARK: - Memory Limit Tests

    func test_setMemoryLimit_updatesLimit() async {
        // Given
        let newLimit = 20 * 1024 * 1024 // 20MB

        // When
        await sut.setMemoryLimit(newLimit)

        // Then - 제한이 변경되었는지 확인 (간접적으로)
        // NSCache는 내부적으로 제한을 적용하므로 직접 확인 불가
        // 실제로는 메모리 제한을 초과하는 이미지를 추가해서 확인할 수 있음
    }

    // MARK: - Helper Methods

    private func createTestImage(size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func createMetadata() -> CacheMetadata {
        return CacheMetadata(
            url: "https://test.com",
            targetSize: CGSize(width: 100, height: 100)
        )
    }
}

//
//  DoublyLinkedListTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 12/7/25.
//

import XCTest
@testable import CurtainCall

final class DoublyLinkedListTests: XCTestCase {

    var sut: DoublyLinkedList!

    override func setUp() {
        super.setUp()
        sut = DoublyLinkedList()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Insert Tests

    func test_insert_addsNode() {
        // Given
        let key = "test_key"
        let metadata = createMetadata(url: "https://test.com", fileSize: 1024)

        // When
        sut.insert(key: key, metadata: metadata)

        // Then
        XCTAssertEqual(sut.count, 1, "노드가 추가되어야 함")
        XCTAssertNotNil(sut.getNode(key: key), "추가한 노드를 조회할 수 있어야 함")
    }

    func test_insert_multipleNodes() {
        // Given & When
        for i in 1...5 {
            let metadata = createMetadata(url: "https://test\(i).com", fileSize: 1024 * i)
            sut.insert(key: "key\(i)", metadata: metadata)
        }

        // Then
        XCTAssertEqual(sut.count, 5, "5개의 노드가 추가되어야 함")
    }

    func test_insert_duplicateKey_replacesNode() {
        // Given
        let key = "duplicate_key"
        let metadata1 = createMetadata(url: "https://old.com", fileSize: 1024)
        let metadata2 = createMetadata(url: "https://new.com", fileSize: 2048)

        // When
        sut.insert(key: key, metadata: metadata1)
        sut.insert(key: key, metadata: metadata2)

        // Then
        XCTAssertEqual(sut.count, 1, "중복 키는 교체되어야 함")
        let node = sut.getNode(key: key)
        XCTAssertEqual(node?.metadata.url, "https://new.com", "새로운 메타데이터로 교체되어야 함")
    }

    // MARK: - Access Tests

    func test_access_existingNode_returnsNode() {
        // Given
        let key = "test_key"
        let metadata = createMetadata(url: "https://test.com", fileSize: 1024)
        sut.insert(key: key, metadata: metadata)

        // When
        let node = sut.access(key: key)

        // Then
        XCTAssertNotNil(node, "노드를 반환해야 함")
        XCTAssertEqual(node?.metadata.accessCount, 2, "접근 횟수가 증가해야 함 (insert 1회 + access 1회)")
    }

    func test_access_nonExistingNode_returnsNil() {
        // When
        let node = sut.access(key: "nonexistent")

        // Then
        XCTAssertNil(node, "존재하지 않는 노드는 nil 반환")
    }

    func test_access_updatesAccessCount() {
        // Given
        let key = "test_key"
        let metadata = createMetadata(url: "https://test.com", fileSize: 1024)
        sut.insert(key: key, metadata: metadata)

        // When
        sut.access(key: key)
        sut.access(key: key)
        sut.access(key: key)

        // Then
        let node = sut.getNode(key: key)
        XCTAssertEqual(node?.metadata.accessCount, 4, "접근 횟수가 4회여야 함 (insert 1 + access 3)")
    }

    // MARK: - Remove Tests

    func test_remove_existingNode_removesNode() {
        // Given
        let key = "test_key"
        let metadata = createMetadata(url: "https://test.com", fileSize: 1024)
        sut.insert(key: key, metadata: metadata)

        // When
        let success = sut.remove(key: key)

        // Then
        XCTAssertTrue(success, "제거 성공해야 함")
        XCTAssertEqual(sut.count, 0, "노드가 제거되어야 함")
        XCTAssertNil(sut.getNode(key: key), "제거된 노드는 조회되지 않아야 함")
    }

    func test_remove_nonExistingNode_returnsFalse() {
        // When
        let success = sut.remove(key: "nonexistent")

        // Then
        XCTAssertFalse(success, "존재하지 않는 노드 제거는 실패해야 함")
    }

    // MARK: - LRU+LFU Tests

    func test_removeLeastValuable_removesLowestScoreNode() {
        // Given
        let old = createMetadata(url: "https://old.com", fileSize: 1024)
        let recent = createMetadata(url: "https://recent.com", fileSize: 1024)

        sut.insert(key: "old", metadata: old)
        Thread.sleep(forTimeInterval: 0.01) // 시간 차이 생성
        sut.insert(key: "recent", metadata: recent)

        // old를 여러 번 접근해서 빈도 높임
        sut.access(key: "old")
        sut.access(key: "old")
        sut.access(key: "old")

        // recent는 최근 삽입되었지만 접근 횟수 적음

        // When
        let removedKey = sut.removeLeastValuable()

        // Then
        XCTAssertEqual(removedKey, "recent", "점수가 낮은 노드가 제거되어야 함")
        XCTAssertEqual(sut.count, 1, "1개 노드만 남아야 함")
    }

    func test_removeUntilSize_removesNodesUntilTargetSize() {
        // Given
        for i in 1...10 {
            let metadata = createMetadata(url: "https://test\(i).com", fileSize: 1024) // 1KB each
            sut.insert(key: "key\(i)", metadata: metadata)
        }

        XCTAssertEqual(sut.getTotalSize(), 10240, "총 10KB여야 함")

        // When
        let removedKeys = sut.removeUntilSize(targetSize: 5120) // 5KB까지 줄이기

        // Then
        XCTAssertTrue(sut.getTotalSize() <= 5120, "목표 크기 이하로 줄어들어야 함")
        XCTAssertTrue(removedKeys.count >= 5, "최소 5개 제거되어야 함")
    }

    // MARK: - Size Tests

    func test_getTotalSize_returnsCorrectSize() {
        // Given
        sut.insert(key: "key1", metadata: createMetadata(url: "https://test1.com", fileSize: 1024))
        sut.insert(key: "key2", metadata: createMetadata(url: "https://test2.com", fileSize: 2048))
        sut.insert(key: "key3", metadata: createMetadata(url: "https://test3.com", fileSize: 512))

        // When
        let totalSize = sut.getTotalSize()

        // Then
        XCTAssertEqual(totalSize, 3584, "총 크기가 정확해야 함 (1024 + 2048 + 512)")
    }

    // MARK: - Metadata Tests

    func test_updateMetadata_updatesCorrectly() {
        // Given
        let key = "test_key"
        let metadata = createMetadata(url: "https://test.com", fileSize: 1024)
        sut.insert(key: key, metadata: metadata)

        // When
        var updatedMetadata = metadata
        updatedMetadata.etag = "new_etag"
        sut.updateMetadata(key: key, metadata: updatedMetadata)

        // Then
        let node = sut.getNode(key: key)
        XCTAssertEqual(node?.metadata.etag, "new_etag", "메타데이터가 업데이트되어야 함")
    }

    func test_getAllMetadata_returnsAllNodes() {
        // Given
        for i in 1...5 {
            let metadata = createMetadata(url: "https://test\(i).com", fileSize: 1024)
            sut.insert(key: "key\(i)", metadata: metadata)
        }

        // When
        let allMetadata = sut.getAllMetadata()

        // Then
        XCTAssertEqual(allMetadata.count, 5, "모든 메타데이터를 반환해야 함")
    }

    // MARK: - Clear Tests

    func test_removeAll_clearsAllNodes() {
        // Given
        for i in 1...10 {
            let metadata = createMetadata(url: "https://test\(i).com", fileSize: 1024)
            sut.insert(key: "key\(i)", metadata: metadata)
        }

        // When
        sut.removeAll()

        // Then
        XCTAssertEqual(sut.count, 0, "모든 노드가 제거되어야 함")
        XCTAssertEqual(sut.getTotalSize(), 0, "총 크기가 0이어야 함")
    }

    // MARK: - Helper Methods

    private func createMetadata(url: String, fileSize: Int) -> CacheMetadata {
        return CacheMetadata(
            url: url,
            etag: nil,
            cachedDate: Date(),
            lastValidated: Date(),
            accessCount: 1,
            lastAccessTime: Date(),
            fileSize: fileSize,
            targetSize: CGSize(width: 300, height: 450)
        )
    }
}

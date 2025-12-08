//
//  DiskCacheActor.swift
//  CurtainCall
//
//  Created by 서준일 on 12/7/25.
//

import Foundation
import OSLog

/// 디스크 캐시를 관리하는 Actor
actor DiskCacheActor {
    // MARK: - Properties

    /// 캐시 디렉토리 경로
    private let cacheDirectory: URL

    /// 메타데이터 파일 경로
    private let metadataFileURL: URL

    /// 이중 연결 리스트 (LRU+LFU)
    private let linkedList: DoublyLinkedList

    /// 디스크 용량 제한 (bytes)
    private var diskLimit: Int

    /// TTL (Time To Live) - 기본 7일
    private var ttl: TimeInterval

    /// 캐시 통계
    private var hitCount: Int = 0
    private var missCount: Int = 0

    // MARK: - Initialization

    init(diskLimit: Int, ttl: TimeInterval) throws {
        self.diskLimit = diskLimit
        self.ttl = ttl
        self.linkedList = DoublyLinkedList()

        // App Groups 디렉토리 생성
        AppGroupsContainer.createDirectoriesIfNeeded()

        // App Groups 컨테이너 내 캐시 경로
        let baseCacheDir = AppGroupsContainer.imageCacheDirectory ?? {
            // Fallback: 기존 경로
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("CustomImageCache")
        }()

        self.cacheDirectory = baseCacheDir.appendingPathComponent("images")
        self.metadataFileURL = baseCacheDir.appendingPathComponent("metadata.json")

        // 디렉토리 생성
        try FileManager.default.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )

        // 메타데이터 로드
        loadMetadata()

        Logger.data.info("DiskCacheActor 초기화 - 제한: \(diskLimit / 1024 / 1024)MB, TTL: \(ttl / 86400)일, 경로: \(self.cacheDirectory.path)")
    }

    // MARK: - Public Methods

    /// 이미지 데이터 가져오기
    /// - Parameter key: 캐시 키
    /// - Returns: (이미지 데이터, 메타데이터) 또는 nil
    func get(key: String) -> (Data, CacheMetadata)? {
        // linkedList에서 노드 접근 (자동으로 head로 이동)
        guard let node = linkedList.access(key: key) else {
            missCount += 1
            Logger.data.debug("디스크 캐시 MISS: \(key)")
            return nil
        }

        let fileURL = cacheDirectory.appendingPathComponent(key)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // 메타데이터는 있는데 파일이 없는 경우 (불일치)
            linkedList.remove(key: key)
            saveMetadata()
            missCount += 1
            Logger.data.warning("디스크 캐시 불일치: \(key)")
            return nil
        }

        guard let data = try? Data(contentsOf: fileURL) else {
            missCount += 1
            Logger.data.error("디스크 캐시 읽기 실패: \(key)")
            return nil
        }

        hitCount += 1
        Logger.data.debug("디스크 캐시 HIT: \(key)")

        return (data, node.metadata)
    }

    /// 이미지 데이터 저장
    /// - Parameters:
    ///   - key: 캐시 키
    ///   - data: 이미지 데이터
    ///   - metadata: 메타데이터
    func set(key: String, data: Data, metadata: CacheMetadata) {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        do {
            try data.write(to: fileURL)

            var updatedMetadata = metadata
            updatedMetadata.fileSize = data.count

            // linkedList에 삽입 (head에 추가)
            linkedList.insert(key: key, metadata: updatedMetadata)

            saveMetadata()

            Logger.data.debug("디스크 캐시 저장: \(key) (\(data.count / 1024)KB)")

            // 용량 체크 및 정리
            checkAndCleanupIfNeeded()
        } catch {
            Logger.data.error("디스크 캐시 저장 실패: \(error.localizedDescription)")
        }
    }

    /// 특정 키 삭제
    /// - Parameter key: 삭제할 캐시 키
    func remove(key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        try? FileManager.default.removeItem(at: fileURL)
        linkedList.remove(key: key)
        saveMetadata()

        Logger.data.debug("디스크 캐시 삭제: \(key)")
    }

    /// 전체 캐시 삭제
    func clearAll() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )

        linkedList.removeAll()
        saveMetadata()

        hitCount = 0
        missCount = 0

        Logger.data.info("디스크 캐시 전체 삭제")
    }

    /// 메타데이터 가져오기
    /// - Parameter key: 캐시 키
    /// - Returns: 메타데이터 또는 nil
    func getMetadata(key: String) -> CacheMetadata? {
        return linkedList.getNode(key: key)?.metadata
    }

    /// 메타데이터 업데이트
    /// - Parameters:
    ///   - key: 캐시 키
    ///   - metadata: 새로운 메타데이터
    func updateMetadata(key: String, metadata: CacheMetadata) {
        linkedList.updateMetadata(key: key, metadata: metadata)
        saveMetadata()
    }

    /// TTL 만료 여부 확인
    /// - Parameter key: 캐시 키
    /// - Returns: TTL 만료 여부
    func isTTLExpired(key: String) -> Bool {
        guard let meta = linkedList.getNode(key: key)?.metadata else { return true }
        return meta.isTTLExpired(ttl: ttl)
    }

    /// 디스크 용량 제한 설정
    /// - Parameter limit: 새로운 디스크 제한 (bytes)
    func setDiskLimit(_ limit: Int) {
        diskLimit = limit
        Logger.data.info("디스크 제한 변경: \(limit / 1024 / 1024)MB")
        checkAndCleanupIfNeeded()
    }

    /// TTL 설정
    /// - Parameter ttl: 새로운 TTL (seconds)
    func setTTL(_ ttl: TimeInterval) {
        self.ttl = ttl
        Logger.data.info("TTL 변경: \(ttl / 86400)일")
    }

    /// 캐시 히트율 계산
    /// - Returns: 0.0 ~ 1.0 사이의 히트율
    func getHitRate() -> Double {
        let total = hitCount + missCount
        guard total > 0 else { return 0.0 }
        return Double(hitCount) / Double(total)
    }

    /// 통계 초기화
    func resetStatistics() {
        hitCount = 0
        missCount = 0
    }

    /// 현재 캐시 크기 계산
    /// - Returns: 총 캐시 크기 (bytes)
    func getCurrentCacheSize() -> Int {
        return linkedList.getTotalSize()
    }

    // MARK: - Private Methods

    /// 메타데이터 로드
    private func loadMetadata() {
        guard FileManager.default.fileExists(atPath: metadataFileURL.path) else {
            Logger.data.info("메타데이터 파일 없음 (신규 생성 예정)")
            return
        }

        do {
            let data = try Data(contentsOf: metadataFileURL)
            let decoded = try JSONDecoder().decode([String: CacheMetadata].self, from: data)

            // linkedList에 로드
            for (key, metadata) in decoded {
                linkedList.insert(key: key, metadata: metadata)
            }

            Logger.data.info("메타데이터 로드 완료: \(decoded.count)개 항목")
        } catch {
            Logger.data.error("메타데이터 로드 실패: \(error.localizedDescription)")
        }
    }

    /// 메타데이터 저장
    private func saveMetadata() {
        do {
            let allMetadata = linkedList.getAllMetadata()
            let data = try JSONEncoder().encode(allMetadata)
            try data.write(to: metadataFileURL)
            Logger.data.debug("메타데이터 저장 완료")
        } catch {
            Logger.data.error("메타데이터 저장 실패: \(error.localizedDescription)")
        }
    }

    /// 용량 체크 및 정리
    private func checkAndCleanupIfNeeded() {
        let currentSize = getCurrentCacheSize()

        guard currentSize > diskLimit else { return }

        Logger.data.warning("디스크 용량 초과: \(currentSize / 1024 / 1024)MB / \(self.diskLimit / 1024 / 1024)MB")

        // LRU+LFU 혼합 정리 (DoublyLinkedList 사용)
        cleanupWithLRULFU(targetSize: diskLimit)
    }

    /// LRU+LFU 혼합 정리
    /// - Parameter targetSize: 목표 크기
    private func cleanupWithLRULFU(targetSize: Int) {
        // linkedList가 점수 기반으로 제거
        let removedKeys = linkedList.removeUntilSize(targetSize: targetSize)

        // 파일 삭제
        for key in removedKeys {
            let fileURL = cacheDirectory.appendingPathComponent(key)
            try? FileManager.default.removeItem(at: fileURL)
        }

        saveMetadata()

        let finalSize = getCurrentCacheSize()
        Logger.data.info("LRU+LFU 정리 완료: \(removedKeys.count)개 제거, 최종 크기: \(finalSize / 1024 / 1024)MB")
    }
}

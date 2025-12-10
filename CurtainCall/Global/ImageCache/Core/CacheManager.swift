//
//  CacheManager.swift
//  CurtainCall
//
//  Created by 서준일 on 12/7/25.
//

import UIKit
import OSLog

/// 메모리 캐시와 디스크 캐시를 조율하는 매니저
actor CacheManager {
    // MARK: - Properties

    /// 메모리 캐시
    private let memoryCache: MemoryCacheActor

    /// 디스크 캐시
    private let diskCache: DiskCacheActor

    /// TTL (Time To Live)
    private let ttl: TimeInterval

    // MARK: - Initialization

    init(memoryLimit: Int, diskLimit: Int, ttl: TimeInterval) throws {
        self.memoryCache = MemoryCacheActor(memoryLimit: memoryLimit)
        self.diskCache = try DiskCacheActor(diskLimit: diskLimit, ttl: ttl)
        self.ttl = ttl

        Logger.data.info("CacheManager 초기화 완료")
    }

    // MARK: - Public Methods

    /// 이미지 가져오기 (메모리 → 디스크 순서로 조회)
    /// - Parameter key: 캐시 키
    /// - Returns: 캐시된 이미지 또는 nil
    func getImage(key: String) async -> UIImage? {
        // 1. 메모리 캐시 확인
        if let image = await memoryCache.get(key: key) {
            Logger.data.debug("캐시 조회 성공 (메모리): \(key)")
            return image
        }

        // 2. 디스크 캐시 확인
        if let (data, _) = await diskCache.get(key: key),
           let image = UIImage(data: data) {
            // 디스크에서 찾았으면 메모리에도 저장
            if let metadata = await diskCache.getMetadata(key: key) {
                await memoryCache.set(key: key, image: image, metadata: metadata)
            }

            Logger.data.debug("캐시 조회 성공 (디스크): \(key)")
            return image
        }

        Logger.data.debug("캐시 조회 실패: \(key)")
        return nil
    }

    /// 이미지 저장 (메모리 + 디스크)
    /// - Parameters:
    ///   - key: 캐시 키
    ///   - image: 저장할 이미지
    ///   - metadata: 메타데이터
    func setImage(key: String, image: UIImage, metadata: CacheMetadata) async {
        // 메모리 캐시 저장
        await memoryCache.set(key: key, image: image, metadata: metadata)

        // 디스크 캐시 저장 (이미지 데이터로 변환)
        if let data = image.jpegData(compressionQuality: 0.9) {
            await diskCache.set(key: key, data: data, metadata: metadata)
        } else if let data = image.pngData() {
            await diskCache.set(key: key, data: data, metadata: metadata)
        }

        Logger.data.debug("이미지 캐싱 완료 (메모리+디스크): \(key)")
    }

    /// 이미지 저장 (메모리만)
    /// - Parameters:
    ///   - key: 캐시 키
    ///   - image: 저장할 이미지
    ///   - metadata: 메타데이터
    func setImageMemoryOnly(key: String, image: UIImage, metadata: CacheMetadata) async {
        // 메모리 캐시만 저장
        await memoryCache.set(key: key, image: image, metadata: metadata)
        Logger.data.debug("이미지 캐싱 완료 (메모리만): \(key)")
    }

    /// 이미지 저장 (디스크만)
    /// - Parameters:
    ///   - key: 캐시 키
    ///   - image: 저장할 이미지
    ///   - metadata: 메타데이터
    func setImageDiskOnly(key: String, image: UIImage, metadata: CacheMetadata) async {
        // 디스크 캐시만 저장 (이미지 데이터로 변환)
        if let data = image.jpegData(compressionQuality: 0.9) {
            await diskCache.set(key: key, data: data, metadata: metadata)
        } else if let data = image.pngData() {
            await diskCache.set(key: key, data: data, metadata: metadata)
        }
        Logger.data.debug("이미지 캐싱 완료 (디스크만): \(key)")
    }

    /// 메타데이터 가져오기
    /// - Parameter key: 캐시 키
    /// - Returns: 메타데이터 또는 nil
    func getMetadata(key: String) async -> CacheMetadata? {
        return await diskCache.getMetadata(key: key)
    }

    /// 메타데이터 업데이트
    /// - Parameters:
    ///   - key: 캐시 키
    ///   - metadata: 새로운 메타데이터
    func updateMetadata(key: String, metadata: CacheMetadata) async {
        await diskCache.updateMetadata(key: key, metadata: metadata)
    }

    /// TTL 만료 여부 확인
    /// - Parameter key: 캐시 키
    /// - Returns: TTL 만료 여부
    func isTTLExpired(key: String) async -> Bool {
        return await diskCache.isTTLExpired(key: key)
    }

    /// 특정 키 삭제
    /// - Parameter key: 삭제할 캐시 키
    func remove(key: String) async {
        await memoryCache.remove(key: key)
        await diskCache.remove(key: key)
    }

    /// 메모리 캐시만 삭제
    func clearMemoryCache() async {
        await memoryCache.clearAll()
        Logger.data.info("메모리 캐시 삭제")
    }

    /// 디스크 캐시만 삭제
    func clearDiskCache() async {
        await diskCache.clearAll()
        Logger.data.info("디스크 캐시 삭제")
    }

    /// 전체 캐시 삭제
    func clearAll() async {
        await memoryCache.clearAll()
        await diskCache.clearAll()
        Logger.data.info("전체 캐시 삭제")
    }

    /// 캐시 통계 가져오기
    /// - Returns: 메모리/디스크 히트율
    func getStatistics() async -> (memoryHitRate: Double, diskHitRate: Double, cacheSize: Int) {
        let memoryHitRate = await memoryCache.getHitRate()
        let diskHitRate = await diskCache.getHitRate()
        let cacheSize = await diskCache.getCurrentCacheSize()

        return (memoryHitRate, diskHitRate, cacheSize)
    }

    /// 통계 초기화
    func resetStatistics() async {
        await memoryCache.resetStatistics()
        await diskCache.resetStatistics()
    }
}

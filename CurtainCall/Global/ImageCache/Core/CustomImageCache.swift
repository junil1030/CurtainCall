//
//  CustomImageCache.swift
//  CurtainCall
//
//  Created by 서준일 on 12/7/25.
//

import UIKit
import OSLog

/// CustomImageCache Public API
final class CustomImageCache {
    // MARK: - Singleton

    static let shared = CustomImageCache()

    // MARK: - Properties

    /// 캐시 매니저
    private var cacheManager: CacheManager?

    /// 네트워크 로더
    private let networkLoader: NetworkLoader

    /// 메모리 제한 (bytes)
    private var memoryLimit: Int

    /// 디스크 제한 (bytes)
    private var diskLimit: Int

    /// TTL (Time To Live) - 기본 7일
    private var ttl: TimeInterval

    // MARK: - Initialization

    private init() {
        // 기본 설정 (Kingfisher와 동일)
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        let memoryLimit = min(Int(Double(physicalMemory) * 0.25), 150 * 1024 * 1024) // 최대 150MB
        let diskLimit = 150 * 1024 * 1024 // 150MB
        let ttl: TimeInterval = 7 * 24 * 60 * 60 // 7일

        self.memoryLimit = memoryLimit
        self.diskLimit = diskLimit
        self.ttl = ttl
        self.networkLoader = NetworkLoader()

        do {
            self.cacheManager = try CacheManager(
                memoryLimit: memoryLimit,
                diskLimit: diskLimit,
                ttl: ttl
            )
            Logger.data.info("CustomImageCache 초기화 완료")
        } catch {
            Logger.data.error("CustomImageCache 초기화 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - Public Methods

    /// 캐시 설정
    /// - Parameters:
    ///   - memoryLimit: 메모리 제한 (bytes), 기본값: 물리 메모리의 25% (최대 150MB)
    ///   - diskLimit: 디스크 제한 (bytes), 기본값: 150MB
    ///   - ttl: TTL (seconds), 기본값: 7일
    func configure(
        memoryLimit: Int? = nil,
        diskLimit: Int? = nil,
        ttl: TimeInterval? = nil
    ) {
        if let memoryLimit = memoryLimit {
            self.memoryLimit = memoryLimit
        }
        if let diskLimit = diskLimit {
            self.diskLimit = diskLimit
        }
        if let ttl = ttl {
            self.ttl = ttl
        }

        // CacheManager 재생성
        do {
            self.cacheManager = try CacheManager(
                memoryLimit: self.memoryLimit,
                diskLimit: self.diskLimit,
                ttl: self.ttl
            )
            Logger.data.info("CustomImageCache 재설정 완료")
        } catch {
            Logger.data.error("CustomImageCache 재설정 실패: \(error.localizedDescription)")
        }
    }

    /// 이미지 로드
    /// - Parameters:
    ///   - url: 이미지 URL
    ///   - targetSize: 타겟 크기 (리사이징용)
    ///   - cacheStrategy: 캐싱 전략 (기본값: .both)
    /// - Returns: 로드된 이미지 또는 nil
    func loadImage(url: URL, targetSize: CGSize, cacheStrategy: CacheStrategy = .both) async -> UIImage? {
        guard let cacheManager = cacheManager else {
            Logger.data.error("CacheManager가 초기화되지 않음")
            return nil
        }

        // 캐시 키 생성
        let cacheKey = generateCacheKey(url: url, size: targetSize)

        // 1. 캐시 조회 (메모리 → 디스크)
        if let cachedImage = await cacheManager.getImage(key: cacheKey) {
            return cachedImage
        }

        // 2. 메타데이터 확인 (ETag 및 TTL 체크)
        let metadata = await cacheManager.getMetadata(key: cacheKey)
        let existingETag = metadata?.etag
        let isTTLExpired = await cacheManager.isTTLExpired(key: cacheKey)

        // 3. 네트워크 다운로드
        do {
            // TTL이 만료되었고 ETag가 있으면 재검증 시도
            let result = try await networkLoader.downloadImage(
                url: url,
                etag: isTTLExpired ? existingETag : nil
            )

            switch result {
            case .success(let data, let newETag):
                // 새 이미지 다운로드 성공
                // 다운샘플링 (메모리 효율적)
                guard let image = ImageResizer.downsample(data: data, targetSize: targetSize) else {
                    Logger.data.error("이미지 다운샘플링 실패")
                    return nil
                }

                // 캐시 저장 (전략에 따라)
                let newMetadata = CacheMetadata(
                    url: url.absoluteString,
                    etag: newETag,
                    targetSize: targetSize
                )

                switch cacheStrategy {
                case .memoryOnly:
                    await cacheManager.setImageMemoryOnly(key: cacheKey, image: image, metadata: newMetadata)
                case .diskOnly:
                    await cacheManager.setImageDiskOnly(key: cacheKey, image: image, metadata: newMetadata)
                case .both:
                    await cacheManager.setImage(key: cacheKey, image: image, metadata: newMetadata)
                }

                return image

            case .notModified:
                // 304 응답 - 기존 캐시 유효
                // 메타데이터의 lastValidated 갱신
                if var existingMetadata = metadata {
                    existingMetadata.markValidated()
                    await cacheManager.updateMetadata(key: cacheKey, metadata: existingMetadata)
                }

                // 디스크 캐시에서 다시 로드
                if let cachedImage = await cacheManager.getImage(key: cacheKey) {
                    Logger.data.info("ETag 재검증 성공 - 캐시 유효")
                    return cachedImage
                }

                Logger.data.warning("304 응답받았지만 캐시에서 이미지를 찾을 수 없음")
                return nil
            }

        } catch {
            Logger.data.error("이미지 다운로드 실패: \(error.localizedDescription)")
            return nil
        }
    }

    /// 이미지 저장 (수동)
    /// - Parameters:
    ///   - image: 저장할 이미지
    ///   - url: 이미지 URL
    ///   - targetSize: 타겟 크기
    ///   - etag: ETag (선택)
    ///   - cacheStrategy: 캐싱 전략 (기본값: .both)
    func saveImage(
        image: UIImage,
        url: URL,
        targetSize: CGSize,
        etag: String? = nil,
        cacheStrategy: CacheStrategy = .both
    ) async {
        guard let cacheManager = cacheManager else { return }

        let cacheKey = generateCacheKey(url: url, size: targetSize)
        let metadata = CacheMetadata(
            url: url.absoluteString,
            etag: etag,
            targetSize: targetSize
        )

        switch cacheStrategy {
        case .memoryOnly:
            await cacheManager.setImageMemoryOnly(key: cacheKey, image: image, metadata: metadata)
        case .diskOnly:
            await cacheManager.setImageDiskOnly(key: cacheKey, image: image, metadata: metadata)
        case .both:
            await cacheManager.setImage(key: cacheKey, image: image, metadata: metadata)
        }
    }

    /// 메모리 캐시 삭제
    func clearMemoryCache() {
        Task {
            await cacheManager?.clearMemoryCache()
        }
    }

    /// 디스크 캐시 삭제
    func clearDiskCache() {
        Task {
            await cacheManager?.clearDiskCache()
        }
    }

    /// 전체 캐시 삭제
    func clearAll() {
        Task {
            await cacheManager?.clearAll()
        }
    }

    /// 통계 가져오기
    /// - Returns: 캐시 통계
    func getStatistics() async -> CacheStatistics? {
        guard let cacheStats = await cacheManager?.getStatistics() else {
            return nil
        }

        let networkStats = await networkLoader.getStatistics()
        let etagHitRate = await networkLoader.getETagHitRate()

        return CacheStatistics(
            memoryHitRate: cacheStats.memoryHitRate,
            diskHitRate: cacheStats.diskHitRate,
            etagHitRate: etagHitRate,
            totalDownloads: networkStats.downloads,
            totalBytesDownloaded: networkStats.downloaded,
            totalBytesSaved: networkStats.saved,
            currentCacheSize: cacheStats.cacheSize
        )
    }

    // MARK: - Private Methods

    /// 캐시 키 생성
    /// - Parameters:
    ///   - url: 이미지 URL
    ///   - size: 타겟 크기
    /// - Returns: 해시된 캐시 키
    private func generateCacheKey(url: URL, size: CGSize) -> String {
        let sizeString = "\(Int(size.width))x\(Int(size.height))"
        let key = "\(url.absoluteString)_\(sizeString)"
        return key.sha256
    }
}

//
//  MemoryCacheActor.swift
//  CurtainCall
//
//  Created by 서준일 on 12/7/25.
//

import UIKit
import OSLog

/// 메모리 캐시를 관리하는 Actor
actor MemoryCacheActor {
    // MARK: - Properties

    /// NSCache를 이용한 이미지 저장소
    private let cache = NSCache<NSString, UIImage>()

    /// 캐시 메타데이터 저장소
    private var metadata: [String: CacheMetadata] = [:]

    /// 메모리 제한 (bytes)
    private var memoryLimit: Int

    /// 캐시 통계
    private var hitCount: Int = 0
    private var missCount: Int = 0

    // MARK: - Initialization

    init(memoryLimit: Int) {
        self.memoryLimit = memoryLimit
        self.cache.totalCostLimit = memoryLimit

        // 메모리 워닝 감지
        let cache = self.cache
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            cache.removeAllObjects()
            Logger.data.warning("메모리 경고: 메모리 캐시 전체 삭제")
        }

        Logger.data.info("MemoryCacheActor 초기화 - 제한: \(memoryLimit / 1024 / 1024)MB")
    }

    // MARK: - Public Methods

    /// 이미지 가져오기
    /// - Parameter key: 캐시 키
    /// - Returns: 캐시된 이미지 (없으면 nil)
    func get(key: String) -> UIImage? {
        if let image = cache.object(forKey: key as NSString) {
            hitCount += 1

            // 메타데이터 접근 기록
            if var meta = metadata[key] {
                meta.recordAccess()
                metadata[key] = meta
            }

            Logger.data.debug("메모리 캐시 HIT: \(key)")
            return image
        } else {
            missCount += 1
            Logger.data.debug("메모리 캐시 MISS: \(key)")
            return nil
        }
    }

    /// 이미지 저장
    /// - Parameters:
    ///   - key: 캐시 키
    ///   - image: 저장할 이미지
    ///   - metadata: 메타데이터
    func set(key: String, image: UIImage, metadata: CacheMetadata) {
        // 이미지 크기 계산 (대략적)
        let cost = estimateImageSize(image)

        cache.setObject(image, forKey: key as NSString, cost: cost)
        self.metadata[key] = metadata

        Logger.data.debug("메모리 캐시 저장: \(key) (\(cost / 1024)KB)")
    }

    /// 특정 키 삭제
    /// - Parameter key: 삭제할 캐시 키
    func remove(key: String) {
        cache.removeObject(forKey: key as NSString)
        metadata.removeValue(forKey: key)
        Logger.data.debug("메모리 캐시 삭제: \(key)")
    }

    /// 전체 캐시 삭제
    func clearAll() {
        cache.removeAllObjects()
        metadata.removeAll()
        hitCount = 0
        missCount = 0
        Logger.data.info("메모리 캐시 전체 삭제")
    }

    /// 메모리 제한 설정
    /// - Parameter limit: 새로운 메모리 제한 (bytes)
    func setMemoryLimit(_ limit: Int) {
        memoryLimit = limit
        cache.totalCostLimit = limit
        Logger.data.info("메모리 제한 변경: \(limit / 1024 / 1024)MB")
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

    // MARK: - Private Methods

    /// 이미지 크기 추정
    /// - Parameter image: 이미지
    /// - Returns: 예상 메모리 사용량 (bytes)
    private func estimateImageSize(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4 // RGBA

        return width * height * bytesPerPixel
    }
}

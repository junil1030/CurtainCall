//
//  UIImageView+CustomCache.swift
//  CurtainCall
//
//  Created by 서준일 on 12/7/25.
//

import UIKit
import OSLog

// MARK: - Associated Keys

private var imageLoadTaskKey: UInt8 = 0

// MARK: - UIImageView Extension

extension UIImageView {
    // MARK: - Associated Object

    /// 현재 진행 중인 이미지 로드 Task
    private var imageLoadTask: Task<Void, Never>? {
        get {
            return objc_getAssociatedObject(self, &imageLoadTaskKey) as? Task<Void, Never>
        }
        set {
            objc_setAssociatedObject(self, &imageLoadTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: - Public Methods

    /// CustomImageCache를 사용하여 이미지 설정
    /// - Parameters:
    ///   - url: 이미지 URL
    ///   - placeholder: 플레이스홀더 이미지 (로딩 중 표시)
    ///   - targetSize: 타겟 크기 (nil이면 현재 bounds.size 사용)
    func setImage(
        with url: URL?,
        placeholder: UIImage? = nil,
        targetSize: CGSize? = nil
    ) {
        // 이전 Task 취소
        cancelImageLoad()

        // placeholder 설정
        image = placeholder

        // URL 확인
        guard let url = url else {
            Logger.data.warning("UIImageView setImage: URL이 nil")
            return
        }

        // targetSize 결정 (nil이면 bounds.size 사용)
        let finalTargetSize: CGSize
        if let targetSize = targetSize, targetSize.width > 0, targetSize.height > 0 {
            finalTargetSize = targetSize
        } else if bounds.size.width > 0, bounds.size.height > 0 {
            finalTargetSize = bounds.size
        } else {
            // bounds가 아직 결정되지 않은 경우, 기본 크기 사용
            finalTargetSize = CGSize(width: 300, height: 300)
            Logger.data.debug("UIImageView bounds 미확정, 기본 크기 사용: \(Int(finalTargetSize.width))x\(Int(finalTargetSize.height))")
        }

        // 새 Task 시작
        let task = Task { @MainActor in
            // Task 취소 확인
            guard !Task.isCancelled else {
                Logger.data.debug("이미지 로드 취소됨: \(url.absoluteString)")
                return
            }

            // CustomImageCache로 이미지 로드
            if let loadedImage = await CustomImageCache.shared.loadImage(
                url: url,
                targetSize: finalTargetSize
            ) {
                // Task 취소 확인 (로드 완료 후)
                guard !Task.isCancelled else {
                    Logger.data.debug("이미지 로드 후 취소됨: \(url.absoluteString)")
                    return
                }

                // 이미지 설정
                self.image = loadedImage
                Logger.data.debug("UIImageView 이미지 설정 완료: \(url.absoluteString)")
            } else {
                Logger.data.warning("이미지 로드 실패: \(url.absoluteString)")
            }
        }

        // Task 저장
        imageLoadTask = task
    }

    /// 현재 진행 중인 이미지 로드 취소
    func cancelImageLoad() {
        imageLoadTask?.cancel()
        imageLoadTask = nil
    }
}

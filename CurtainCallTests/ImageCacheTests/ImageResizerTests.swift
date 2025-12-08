//
//  ImageResizerTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 12/7/25.
//

import XCTest
@testable import CurtainCall

final class ImageResizerTests: XCTestCase {

    // MARK: - Resize Tests

    func test_resize_largerImage_resizesToTarget() {
        // Given
        let originalSize = CGSize(width: 1000, height: 1500)
        let targetSize = CGSize(width: 300, height: 450)
        let originalImage = createTestImage(size: originalSize)

        // When
        let resizedImage = ImageResizer.resize(image: originalImage, targetSize: targetSize)

        // Then
        XCTAssertNotNil(resizedImage, "리사이징된 이미지가 있어야 함")
        XCTAssertTrue(resizedImage.size.width <= targetSize.width, "너비가 타겟 이하여야 함")
        XCTAssertTrue(resizedImage.size.height <= targetSize.height, "높이가 타겟 이하여야 함")
    }

    func test_resize_smallerImage_returnsOriginal() {
        // Given
        let originalSize = CGSize(width: 200, height: 300)
        let targetSize = CGSize(width: 300, height: 450)
        let originalImage = createTestImage(size: originalSize)

        // When
        let resizedImage = ImageResizer.resize(image: originalImage, targetSize: targetSize)

        // Then
        XCTAssertEqual(resizedImage.size, originalSize, "작은 이미지는 원본 반환해야 함")
    }

    func test_resize_maintainsAspectRatio() {
        // Given
        let originalSize = CGSize(width: 1000, height: 2000) // 1:2 비율
        let targetSize = CGSize(width: 500, height: 500) // 정사각형 타겟
        let originalImage = createTestImage(size: originalSize)

        // When
        let resizedImage = ImageResizer.resize(image: originalImage, targetSize: targetSize)

        // Then
        let originalRatio = originalSize.width / originalSize.height
        let resizedRatio = resizedImage.size.width / resizedImage.size.height

        XCTAssertEqual(originalRatio, resizedRatio, accuracy: 0.01, "비율이 유지되어야 함")
    }

    func test_resize_zeroTargetSize_returnsOriginal() {
        // Given
        let originalSize = CGSize(width: 500, height: 750)
        let targetSize = CGSize.zero
        let originalImage = createTestImage(size: originalSize)

        // When
        let resizedImage = ImageResizer.resize(image: originalImage, targetSize: targetSize)

        // Then
        XCTAssertEqual(resizedImage.size, originalSize, "zero 크기는 원본 반환해야 함")
    }

    // MARK: - Downsample Tests

    func test_downsample_validData_returnsImage() {
        // Given
        let originalSize = CGSize(width: 1000, height: 1500)
        let targetSize = CGSize(width: 300, height: 450)
        let image = createTestImage(size: originalSize)
        let data = image.pngData()!

        // When
        let downsampledImage = ImageResizer.downsample(data: data, targetSize: targetSize)

        // Then
        XCTAssertNotNil(downsampledImage, "다운샘플링된 이미지가 있어야 함")
    }

    func test_downsample_invalidData_returnsNil() {
        // Given
        let invalidData = Data([0x00, 0x01, 0x02])
        let targetSize = CGSize(width: 300, height: 450)

        // When
        let downsampledImage = ImageResizer.downsample(data: invalidData, targetSize: targetSize)

        // Then
        XCTAssertNil(downsampledImage, "유효하지 않은 데이터는 nil 반환해야 함")
    }

    func test_downsample_smallerThanTarget_returnsOriginal() {
        // Given
        let originalSize = CGSize(width: 200, height: 300)
        let targetSize = CGSize(width: 500, height: 750)
        let image = createTestImage(size: originalSize)
        let data = image.pngData()!

        // When
        let downsampledImage = ImageResizer.downsample(data: data, targetSize: targetSize)

        // Then
        XCTAssertNotNil(downsampledImage, "이미지가 반환되어야 함")
        // 작은 이미지는 다운샘플링하지 않음
    }

    // MARK: - Helper Methods

    /// 테스트용 이미지 생성
    private func createTestImage(size: CGSize, color: UIColor = .red) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

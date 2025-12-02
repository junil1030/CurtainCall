//
//  UpdateProfileImageUseCaseTests.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import XCTest
import UIKit
@testable import CurtainCall

final class UpdateProfileImageUseCaseTests: XCTestCase {

    private var sut: UpdateProfileImageUseCase!
    private var mockRepository: MockUserRepository!
    private var mockImageStorage: MockImageStorage!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        mockImageStorage = MockImageStorage()
        sut = UpdateProfileImageUseCase(
            repository: mockRepository,
            imageStorage: mockImageStorage
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockImageStorage = nil
        super.tearDown()
    }

    func test_execute_savesImageAndUpdatesRepository() {
        // Given
        let image = createTestImage()

        // When
        let result = sut.execute(image)

        // Then
        switch result {
        case .success(let imagePath):
            XCTAssertFalse(imagePath.isEmpty, "이미지 경로가 반환되어야 합니다.")
            XCTAssertEqual(mockRepository.getUserProfileImageURL(), imagePath, "Repository에 이미지 경로가 저장되어야 합니다.")
        case .failure(let error):
            XCTFail("성공해야 하는데 에러 발생: \(error)")
        }
    }

    func test_execute_whenImageStorageThrowsError_returnsFailure() {
        // Given
        let image = createTestImage()
        mockImageStorage.shouldThrowError = true
        mockImageStorage.errorToThrow = NSError(domain: "StorageError", code: 400, userInfo: nil)

        // When
        let result = sut.execute(image)

        // Then
        switch result {
        case .success:
            XCTFail("이미지 저장 실패 시 에러가 발생해야 합니다.")
        case .failure(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "StorageError", "Storage 에러가 반환되어야 합니다.")
        }
    }

    func test_execute_whenRepositoryThrowsError_returnsFailure() {
        // Given
        let image = createTestImage()
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NSError(domain: "RepositoryError", code: 500, userInfo: nil)

        // When
        let result = sut.execute(image)

        // Then
        switch result {
        case .success:
            XCTFail("Repository 실패 시 에러가 발생해야 합니다.")
        case .failure(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "RepositoryError", "Repository 에러가 반환되어야 합니다.")
        }
    }

    // MARK: - Helper
    private func createTestImage() -> UIImage {
        return UIImage(systemName: "person.circle") ?? UIImage()
    }
}

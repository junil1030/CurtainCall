//
//  MockImageStorage.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import UIKit
@testable import CurtainCall

final class MockImageStorage: ImageStorageProtocol {

    // MARK: - Mock Data Storage
    private var savedImagePath: String?
    private var savedImage: UIImage?

    // MARK: - Mock Error Control
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: -1, userInfo: nil)

    // MARK: - ImageStorageProtocol
    func saveProfileImage(_ image: UIImage) throws -> String {
        if shouldThrowError {
            throw errorToThrow
        }
        let path = "/mock/path/profile_\(UUID().uuidString).jpg"
        savedImagePath = path
        savedImage = image
        return path
    }

    func loadProfileImage() -> UIImage? {
        return savedImage
    }

    func loadProfileImage(from urlString: String) -> UIImage? {
        if urlString == savedImagePath {
            return savedImage
        }
        return nil
    }

    func deleteProfileImage() throws {
        if shouldThrowError {
            throw errorToThrow
        }
        savedImagePath = nil
        savedImage = nil
    }

    func getProfileImagePath() -> String {
        return savedImagePath ?? ""
    }

    func hasProfileImage() -> Bool {
        return savedImagePath != nil && savedImage != nil
    }

    // MARK: - Test Helpers
    func reset() {
        savedImagePath = nil
        savedImage = nil
        shouldThrowError = false
    }
}

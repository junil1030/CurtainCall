//
//  MockUserRepository.swift
//  CurtainCallTests
//
//  Created by 서준일 on 11/10/25.
//

import Foundation
@testable import CurtainCall

final class MockUserRepository: UserRepositoryProtocol {

    // MARK: - Mock Data Storage
    private var user: UserProfile?

    // MARK: - Mock Error Control
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: -1, userInfo: nil)

    // MARK: - Read
    func getUser() -> UserProfile? {
        return user
    }

    func getUserNickname() -> String {
        return user?.nickname ?? "닉네임"
    }

    func getUserProfileImageURL() -> String {
        return user?.profileImageURL ?? ""
    }

    func getUserCreatedAt() -> Date {
        return user?.createdAt ?? Date()
    }

    // MARK: - Update
    func updateNickname(_ nickname: String) throws {
        if shouldThrowError {
            throw errorToThrow
        }

        if user == nil {
            user = UserProfile(nickname: nickname)
        } else {
            user?.nickname = nickname
            user?.updatedAt = Date()
        }
    }

    func updateProfileImage(_ imageURL: String) throws {
        if shouldThrowError {
            throw errorToThrow
        }

        if user == nil {
            user = UserProfile()
        }
        user?.profileImageURL = imageURL
        user?.updatedAt = Date()
    }

    func updateUser(nickname: String?, profileImageURL: String?) throws {
        if shouldThrowError {
            throw errorToThrow
        }

        if user == nil {
            user = UserProfile()
        }

        if let nickname = nickname {
            user?.nickname = nickname
        }
        if let profileImageURL = profileImageURL {
            user?.profileImageURL = profileImageURL
        }
        user?.updatedAt = Date()
    }

    // MARK: - Delete
    func deleteUser() throws {
        if shouldThrowError {
            throw errorToThrow
        }
        user = nil
    }

    func resetUser() throws {
        if shouldThrowError {
            throw errorToThrow
        }
        user = UserProfile()
    }

    // MARK: - Validation
    func validateNickname(_ nickname: String) -> Bool {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 10
    }

    // MARK: - Test Helpers
    func reset() {
        user = nil
        shouldThrowError = false
    }

    func setUser(_ userProfile: UserProfile) {
        user = userProfile
    }
}

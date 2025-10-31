//
//  UserRepository.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import Foundation
import RealmSwift
import OSLog

final class UserRepository: UserRepositoryProtocol {
    
    // MARK: - Properties
    private let realmProvider: RealmProvider
    private let imageStorage: ImageStorageProtocol
    private let mainUserId = "main_user"
    
    // MARK: - Init
    init(realmProvider: RealmProvider, imageStorage: ImageStorageProtocol) {
        Logger.data.info("👤 UserRepository init 시작")
        self.realmProvider = realmProvider
        self.imageStorage = imageStorage
        Logger.data.info("👤 UserRepository init 완료")
    }
    
    // MARK: - Create
    private func createDefaultUser() throws {
        let realm = try realmProvider.realm()
        
        try realm.write {
            let user = UserProfile(nickname: "닉네임")
            user.id = mainUserId
            realm.add(user)
            Logger.data.info("기본 사용자 생성 성공")
        }
    }
    
    // MARK: - Read
    func getUser() -> UserProfile? {
        do {
            let realm = try realmProvider.realm()
            
            if let user = realm.object(ofType: UserProfile.self, forPrimaryKey: mainUserId) {
                return user
            } else {
                // 사용자가 없으면 생성
                try createDefaultUser()
                return realm.object(ofType: UserProfile.self, forPrimaryKey: mainUserId)
            }
        } catch {
            Logger.data.error("사용자 조회 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getUserNickname() -> String {
        return getUser()?.nickname ?? "닉네임"
    }
    
    func getUserProfileImageURL() -> String {
        return getUser()?.profileImageURL ?? ""
    }
    
    func getUserCreatedAt() -> Date {
        return getUser()?.createdAt ?? Date()
    }
    
    // MARK: - Update
    func updateNickname(_ nickname: String) throws {
        // 닉네임 유효성 검사
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedNickname.isEmpty else {
            throw NSError(domain: "UserRepository", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "닉네임은 비어있을 수 없습니다."
            ])
        }
        
        guard trimmedNickname.count <= 10 else {
            throw NSError(domain: "UserRepository", code: -2, userInfo: [
                NSLocalizedDescriptionKey: "닉네임은 10자 이하여야 합니다."
            ])
        }
        
        let realm = try realmProvider.realm()
        
        guard let user = realm.object(ofType: UserProfile.self, forPrimaryKey: mainUserId) else {
            throw NSError(domain: "UserRepository", code: -3, userInfo: [
                NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."
            ])
        }
        
        try realm.write {
            user.nickname = trimmedNickname
            user.updatedAt = Date()
        }
        
        Logger.data.info("닉네임 업데이트 성공: \(trimmedNickname)")
    }
    
    func updateProfileImage(_ imageURL: String) throws {
        let realm = try realmProvider.realm()
        
        guard let user = realm.object(ofType: UserProfile.self, forPrimaryKey: mainUserId) else {
            throw NSError(domain: "UserRepository", code: -3, userInfo: [
                NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."
            ])
        }
        
        try realm.write {
            user.profileImageURL = imageURL
            user.updatedAt = Date()
        }
        
        Logger.data.info("프로필 이미지 업데이트 성공")    }
    
    func updateUser(nickname: String? = nil, profileImageURL: String? = nil) throws {
        let realm = try realmProvider.realm()
        
        guard let user = realm.object(ofType: UserProfile.self, forPrimaryKey: mainUserId) else {
            throw NSError(domain: "UserRepository", code: -3, userInfo: [
                NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."
            ])
        }
        
        try realm.write {
            if let nickname = nickname {
                let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedNickname.isEmpty && trimmedNickname.count <= 10 else {
                    throw NSError(domain: "UserRepository", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "올바르지 않은 닉네임입니다."
                    ])
                }
                user.nickname = trimmedNickname
            }
            
            if let profileImageURL = profileImageURL {
                user.profileImageURL = profileImageURL
            }
            
            user.updatedAt = Date()
        }
        
        Logger.data.info("사용자 정보 업데이트 성공")
    }
    
    // MARK: - Delete
    func deleteUser() throws {
        let realm = try realmProvider.realm()
        
        guard let user = realm.object(ofType: UserProfile.self, forPrimaryKey: mainUserId) else {
            Logger.data.warning("삭제할 사용자를 찾을 수 없음")
            return
        }
        
        try? imageStorage.deleteProfileImage()
        
        try realm.write {
            realm.delete(user)
        }
        
        Logger.data.info("사용자 삭제 성공")
    }
    
    func resetUser() throws {
        try deleteUser()
        try createDefaultUser()
        Logger.data.info("사용자 초기화 성공")
    }
    
    // MARK: - Validation
    func validateNickname(_ nickname: String) -> Bool {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedNickname.isEmpty && trimmedNickname.count <= 10
    }
}

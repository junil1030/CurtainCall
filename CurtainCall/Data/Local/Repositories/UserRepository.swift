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
    private let realmManager = RealmManager.shared
    private let mainUserId = "main_user"
    
    // MARK: - Create
    private func createDefaultUser() throws {
        do {
            try realmManager.write { realm in
                // 기본 사용자 생성
                let user = UserProfile(nickname: "닉네임")
                user.id = mainUserId
                realm.add(user)
                Logger.data.info("기본 사용자 생성 성공")
            }
        } catch {
            Logger.data.error("기본 사용자 생성 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Read
    func getUser() -> UserProfile? {
        do {
            let realm = try realmManager.getRealm()
            
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
        
        do {
            try realmManager.write { realm in
                guard let user = realm.object(ofType: UserProfile.self, forPrimaryKey: mainUserId) else {
                    throw NSError(domain: "UserRepository", code: -3, userInfo: [
                        NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."
                    ])
                }
                
                user.nickname = trimmedNickname
                user.updatedAt = Date()
                Logger.data.info("닉네임 업데이트 성공: \(trimmedNickname)")
            }
        } catch {
            Logger.data.error("닉네임 업데이트 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateProfileImage(_ imageURL: String) throws {
        do {
            try realmManager.write { realm in
                guard let user = realm.object(ofType: UserProfile.self, forPrimaryKey: mainUserId) else {
                    throw NSError(domain: "UserRepository", code: -3, userInfo: [
                        NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."
                    ])
                }
                
                user.profileImageURL = imageURL
                user.updatedAt = Date()
                Logger.data.info("프로필 이미지 업데이트 성공")
            }
        } catch {
            Logger.data.error("프로필 이미지 업데이트 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateUser(nickname: String? = nil, profileImageURL: String? = nil) throws {
        do {
            try realmManager.write { realm in
                guard let user = realm.object(ofType: UserProfile.self, forPrimaryKey: mainUserId) else {
                    throw NSError(domain: "UserRepository", code: -3, userInfo: [
                        NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."
                    ])
                }
                
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
                Logger.data.info("사용자 정보 업데이트 성공")
            }
        } catch {
            Logger.data.error("사용자 정보 업데이트 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Delete
    func deleteUser() throws {
        do {
            try realmManager.write { realm in
                guard let user = realm.object(ofType: UserProfile.self, forPrimaryKey: mainUserId) else {
                    throw NSError(domain: "UserRepository", code: -3, userInfo: [
                        NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."
                    ])
                }
                
                realm.delete(user)
                Logger.data.info("사용자 삭제 성공")
            }
        } catch {
            Logger.data.error("사용자 삭제 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    func resetUser() throws {
        do {
            try deleteUser()
            try createDefaultUser()
            Logger.data.info("사용자 초기화 성공")
        } catch {
            Logger.data.error("사용자 초기화 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Validation
    func validateNickname(_ nickname: String) -> Bool {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedNickname.isEmpty && trimmedNickname.count <= 10
    }
    
    // MARK: - User Statistics
    func getUserStatistics() -> UserStatistics {
        guard let user = getUser() else {
            return UserStatistics(
                nickname: "닉네임",
                joinedDays: 0,
                totalViewingCount: 0,
                totalFavoriteCount: 0
            )
        }
        
        let joinedDays = Calendar.current.dateComponents([.day], from: user.createdAt, to: Date()).day ?? 0
        
        // 다른 Repository에서 통계 가져오기
        let viewingRepository = ViewingRecordRepository()
        let favoriteRepository = FavoriteRepository()
        
        let totalViewingCount = viewingRepository.getRecordCount()
        let totalFavoriteCount = favoriteRepository.getFavoriteCount()
        
        return UserStatistics(
            nickname: user.nickname,
            joinedDays: joinedDays,
            totalViewingCount: totalViewingCount,
            totalFavoriteCount: totalFavoriteCount
        )
    }
}

// MARK: - Statistics Model
struct UserStatistics {
    let nickname: String
    let joinedDays: Int
    let totalViewingCount: Int
    let totalFavoriteCount: Int
    
    var level: Int {
        // 레벨 계산 로직: 관람 기록 * 10 + 찜 개수
        let totalExp = totalViewingCount * 10 + totalFavoriteCount
        return max(1, totalExp / 30) // 30 경험치당 1레벨
    }
    
    var currentExp: Int {
        let totalExp = totalViewingCount * 10 + totalFavoriteCount
        return totalExp % 30
    }
    
    var maxExp: Int {
        return 30
    }
    
    var experienceData: ProfileExperienceData {
        return ProfileExperienceData(
            nickname: nickname,
            subtitle: "커튼콜과 함께한지 \(joinedDays)일",
            level: level,
            currentExp: currentExp,
            maxExp: maxExp
        )
    }
}

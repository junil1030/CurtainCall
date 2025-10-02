//
//  UserRepositoryProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation

protocol UserRepositoryProtocol {
    // Read
    func getUser() -> UserProfile?
    func getUserNickname() -> String
    func getUserProfileImageURL() -> String
    func getUserCreatedAt() -> Date
    
    // Update
    func updateNickname(_ nickname: String) throws
    func updateProfileImage(_ imageURL: String) throws
    func updateUser(nickname: String?, profileImageURL: String?) throws
    
    // Delete
    func deleteUser() throws
    func resetUser() throws
    
    // Validation
    func validateNickname(_ nickname: String) -> Bool
    
    // Statistics
    func getUserStatistics() -> UserStatistics
}

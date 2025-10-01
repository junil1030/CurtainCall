//
//  UserRepositoryProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation

protocol UserRepositoryProtocol {
    func getUser() -> UserProfile?
    func updateNickname(_ nickname: String) throws
    func updateProfileImage(_ imageURL: String) throws
}

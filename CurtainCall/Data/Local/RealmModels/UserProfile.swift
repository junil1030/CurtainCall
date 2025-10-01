//
//  UserProfile.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation
import RealmSwift

class UserProfile: Object {
    @Persisted(primaryKey: true) var id: String = "main_user"  // 단일 유저니까 고정값
    @Persisted var nickname: String = "닉네임"                  // 기본값
    @Persisted var profileImageURL: String = ""                 // 프로필 이미지 URL
    @Persisted var createdAt: Date = Date()                     // 가입일
    @Persisted var updatedAt: Date = Date()                     // 수정일
    
    convenience init(nickname: String) {
        self.init()
        self.nickname = nickname
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

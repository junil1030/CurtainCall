//
//  DIContainer+Data.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

import Foundation
import OSLog

// MARK: - Data Layer
extension DIContainer {
    
    // Data 계층 의존성 등록 (Repository)
    func registerRepositories() {
        Logger.data.info("🗃️ Repositories 등록 시작")
        
        // MARK: - User Repository (임시로 ImageStorage 의존성 제거)
        register(UserRepositoryProtocol.self) {
            Logger.data.info("👤 UserRepository 생성 시작")
            let realmProvider = self.resolve(RealmProvider.self)
            Logger.data.info("👤 RealmProvider 해결 완료")
            // 임시로 ImageStorage 의존성 제거
            let imageStorage = ProfileImageManager() // 직접 생성
            Logger.data.info("👤 UserRepository 생성 완료")
            return UserRepository(realmProvider: realmProvider, imageStorage: imageStorage)
        }
        
        // MARK: - Favorite Repository
        register(FavoriteRepositoryProtocol.self) {
            Logger.data.info("⭐ FavoriteRepository 생성 시작")
            let realmProvider = self.resolve(RealmProvider.self)
            Logger.data.info("⭐ FavoriteRepository 생성 완료")
            return FavoriteRepository(realmProvider: realmProvider)
        }
        
        // MARK: - Viewing Record Repository
        register(ViewingRecordRepositoryProtocol.self) {
            Logger.data.info("📝 ViewingRecordRepository 생성 시작")
            let realmProvider = self.resolve(RealmProvider.self)
            Logger.data.info("📝 ViewingRecordRepository 생성 완료")
            return ViewingRecordRepository(realmProvider: realmProvider)
        }
        
        // MARK: - Recent Search Repository
        register(RecentSearchRepositoryProtocol.self) {
            Logger.data.info("🔍 RecentSearchRepository 생성 시작")
            let realmProvider = self.resolve(RealmProvider.self)
            Logger.data.info("🔍 RecentSearchRepository 생성 완료")
            return RecentSearchRepository(realmProvider: realmProvider)
        }
        
        Logger.data.info("✅ Repositories 등록 완료")
    }
}

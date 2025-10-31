//
//  DIContainer+Infrastructure.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

import Foundation
import OSLog

// MARK: - Infrastructure Layer
extension DIContainer {
    
    func registerInfrastructure() {
        Logger.data.info("🏗️ Infrastructure 등록 시작")
        
        // MARK: - Realm Provider
        register(RealmProvider.self) {
            Logger.data.info("🗄️ DefaultRealmProvider 생성")
            return DefaultRealmProvider()
        }
        
        // MARK: - Network Manager
        register(NetworkManagerProtocol.self) {
            Logger.data.info("🌐 NetworkManager 생성")
            return NetworkManager()
        }
        
        // MARK: - Image Storage
        register(ImageStorageProtocol.self) {
            Logger.data.info("📸 ProfileImageManager 생성")
            return ProfileImageManager()
        }
        
        Logger.data.info("✅ Infrastructure 등록 완료")
    }
}

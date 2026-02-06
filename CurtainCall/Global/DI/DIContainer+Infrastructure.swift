//
//  DIContainer+Infrastructure.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

import Foundation
import OSLog
import CachingKit

// MARK: - Infrastructure Layer
extension DIContainer {

    func registerInfrastructure() {
        Logger.data.info("🏗️ Infrastructure 등록 시작")

        // MARK: - CachingKit Configuration
        configureCachingKit()

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

    // MARK: - CachingKit Configuration

    /// CachingKit 캐싱 설정
    /// 필요시 이 메서드에서 설정값을 변경할 수 있습니다
    private func configureCachingKit() {
        // 현재는 기본 설정 사용
        // 기본값:
        // - memoryLimit: 물리 메모리의 25% (최대 150MB)
        // - diskLimit: 150MB
        // - ttl: 7일
        //
        // 커스텀 설정이 필요한 경우:
        // let config = CacheConfiguration(
        //     memoryLimit: 100 * 1024 * 1024, // 100MB
        //     diskLimit: 200 * 1024 * 1024,   // 200MB
        //     ttl: 14 * 24 * 60 * 60          // 14일
        // )
        // let _ = CachingKit(configuration: config)

        Logger.data.info("🖼️ CachingKit 초기화 완료 (기본 설정)")
    }
}

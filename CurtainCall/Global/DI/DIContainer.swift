//
//  DIContainer.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

import Foundation
import OSLog

final class DIContainer {
    
    // MARK: - Singleton
    static let shared = DIContainer()
    
    // MARK: - Properties
    private var services: [String: Any] = [:]
    private let lock = NSLock()
    
    // MARK: - Init
    private init() {
        Logger.data.info("🏗️ DIContainer 초기화 시작")
        registerDependencies()
        registerUseCases()
        Logger.data.info("✅ DIContainer 초기화 완료")
    }
    
    // MARK: - Register Dependencies
    private func registerDependencies() {
        Logger.data.info("📦 Dependencies 등록 시작")
        registerInfrastructure()
        registerRepositories()
        Logger.data.info("✅ Dependencies 등록 완료")
    }
    
    // MARK: - Register
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        lock.lock()
        defer { lock.unlock() }
        
        let key = String(describing: type)
        Logger.data.info("📝 등록: \(key)")
        services[key] = factory
    }
    
    // MARK: - Resolve
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        Logger.data.info("🔍 해결 시작: \(key)")
        
        // factory 획득을 위한 짧은 lock
        let factory: () -> T
        lock.lock()
        guard let factoryFunc = services[key] as? () -> T else {
            lock.unlock()
            Logger.data.error("❌ 해결 실패: [\(key)] 타입이 등록되지 않았습니다.")
            fatalError("[\(key)] 타입이 등록되지 않았습니다. DIContainer에 먼저 등록해주세요.")
        }
        factory = factoryFunc
        lock.unlock()
        
        // factory 실행은 lock 밖에서 (recursive resolve 허용)
        let result = factory()
        Logger.data.info("✅ 해결 완료: \(key)")
        return result
    }
    
    // MARK: - Reset (테스트용)
    #if DEBUG
    func reset() {
        lock.lock()
        defer { lock.unlock() }
        
        services.removeAll()
        registerDependencies()
    }
    #endif
}

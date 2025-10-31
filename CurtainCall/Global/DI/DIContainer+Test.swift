//
//  DIContainer+Test.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

#if DEBUG
import UIKit
import RealmSwift
import Parsely

extension DIContainer {
    
    /// 테스트용 Mock 의존성 등록
    func registerMocks() {
        // Mock RealmProvider
        register(RealmProvider.self) {
            return MockRealmProvider()
        }
        
        // Mock NetworkManager
        register(NetworkManagerProtocol.self) {
            return MockNetworkManager()
        }
        
        // Mock ImageStorage
        register(ImageStorageProtocol.self) {
            return MockImageStorage()
        }
    }
}

// MARK: - Mock Implementations (예시)

private final class MockRealmProvider: RealmProvider {
    func realm() throws -> Realm {
        // 인메모리 Realm 반환
        let config = Realm.Configuration(inMemoryIdentifier: "test")
        return try Realm(configuration: config)
    }
    
    func compact() {
        // Mock 구현 - 아무 작업 안함
    }
    
    func initializeDefaultUser() throws {
        // Mock 구현 - 기본 유저 생성
        let realm = try self.realm()
        if realm.objects(UserProfile.self).first == nil {
            try realm.write {
                let defaultUser = UserProfile(nickname: "테스트 유저")
                realm.add(defaultUser)
            }
        }
    }
    
    func printDebugInfo() {
        // Mock 구현 - 디버그 정보 출력
        print("Mock Realm 디버그 정보")
    }
}

private final class MockNetworkManager: NetworkManagerProtocol {
    func request<T: ParselyType>(_ router: APIRouter, responseType: T.Type) async throws -> T {
        // Mock 데이터 반환
        fatalError("Mock 구현 필요")
    }
}

private final class MockImageStorage: ImageStorageProtocol {
    private var savedImage: UIImage?
    
    func saveProfileImage(_ image: UIImage) throws -> String {
        savedImage = image
        return "mock_profile.jpg"
    }
    
    func loadProfileImage() -> UIImage? {
        return savedImage
    }
    
    func loadProfileImage(from urlString: String) -> UIImage? {
        return savedImage
    }
    
    func deleteProfileImage() throws {
        savedImage = nil
    }
    
    func getProfileImagePath() -> String {
        return "mock_profile.jpg"
    }
    
    func hasProfileImage() -> Bool {
        return savedImage != nil
    }}

#endif

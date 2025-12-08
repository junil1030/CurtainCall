//
//  DefaultRealmProvider.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

import Foundation
import RealmSwift
import OSLog

// Realm 인스턴스를 제공하는 기본 구현체
final class DefaultRealmProvider: RealmProvider {
    
    // MARK: - Schema Version
    private enum RealmSchemaVersion: UInt64 {
        case initial = 1
        case changeGenreCode = 2
        
        static var current: UInt64 {
            return RealmSchemaVersion.changeGenreCode.rawValue
        }
    }
    
    // MARK: - Configuration
    private let configuration: Realm.Configuration
    
    // MARK: - Init
    init() {
        // App Groups 디렉토리 생성
        AppGroupsContainer.createDirectoriesIfNeeded()

        // App Groups 컨테이너 내 Realm 파일 경로
        let fileURL = AppGroupsContainer.realmFileURL ?? {
            // Fallback: 기존 경로
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documentsURL.appendingPathComponent("default.realm")
        }()

        self.configuration = Realm.Configuration(
            fileURL: fileURL,
            schemaVersion: RealmSchemaVersion.current,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < RealmSchemaVersion.current {
                    Self.performMigration(migration: migration, oldVersion: oldSchemaVersion)
                }
            },
            deleteRealmIfMigrationNeeded: false,
            objectTypes: [
                UserProfile.self,
                FavoritePerformance.self,
                ViewingRecord.self,
                RecentSearchKeyword.self
            ]
        )

        // 기본 Configuration 설정
        Realm.Configuration.defaultConfiguration = configuration

        Logger.data.info("RealmProvider 초기화 완료 - 경로: \(fileURL.path)")
    }
    
    // MARK: - RealmProvider
    func realm() throws -> Realm {
        return try Realm(configuration: configuration)
    }
    
    // MARK: - Migration
    private static func performMigration(migration: Migration, oldVersion: UInt64) {
        Logger.data.info("마이그레이션 시작: v\(oldVersion) -> v\(RealmSchemaVersion.current)")
        
        // v1(initial) -> v2(changeGenreCode) 마이그레이션
        if oldVersion < RealmSchemaVersion.changeGenreCode.rawValue {
            migrateToChangeGenreCode(migration: migration)
        }
    }
    
    // MARK: - Migration Methods
    private static func migrateToChangeGenreCode(migration: Migration) {
        migration.enumerateObjects(ofType: ViewingRecord.className()) { oldObject, newObject in
            guard let oldObject = oldObject,
                  let newObject = newObject else { return }
            
            if let oldGenre = oldObject["genre"] as? String, !oldGenre.isEmpty {
                let genreCode = convertDisplayNameToCode(oldGenre)
                newObject["genre"] = genreCode
                Logger.data.debug("장르 마이그레이션: \(oldGenre) -> \(genreCode)")
            }
        }
        
        Logger.data.info("v\(RealmSchemaVersion.initial.rawValue) -> v\(RealmSchemaVersion.changeGenreCode.rawValue) 마이그레이션 완료")
    }
    
    // MARK: - Migration Helper
    private static func convertDisplayNameToCode(_ displayName: String) -> String {
        let cleanedDisplayName = removeParenthesesContent(from: displayName)
        
        if let genreCode = GenreCode.allCases.first(where: { $0.displayName == cleanedDisplayName }) {
            return genreCode.rawValue
        }
        
        if let genreCode = GenreCode.allCases.first(where: { $0.displayName == displayName }) {
            return genreCode.rawValue
        }
        
        if GenreCode(rawValue: displayName) != nil {
            return displayName
        }
        
        Logger.data.warning("알 수 없는 장르 값: \(displayName)")
        return displayName
    }
    
    private static func removeParenthesesContent(from text: String) -> String {
        return text.replacingOccurrences(of: "\\([^)]*\\)", with: "", options: .regularExpression)
    }
}

// MARK: - Utility Methods
extension DefaultRealmProvider {
    // Realm 파일 경로를 반환
    func getRealmFileURL() -> URL? {
        return configuration.fileURL
    }
    
    // Realm 파일 크기
    func getRealmFileSize() -> Double {
        guard let fileURL = configuration.fileURL else { return 0 }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? NSNumber {
                return fileSize.doubleValue / (1024 * 1024)
            }
        } catch {
            Logger.data.error("파일 크기 확인 실패: \(error.localizedDescription)")
        }
        
        return 0
    }
    
    // Realm 디버그 정보를 출력
    func printDebugInfo() {
        do {
            let realm = try self.realm()
            Logger.data.debug("Realm 디버그 정보")
            Logger.data.debug("- 스키마 버전: \(realm.configuration.schemaVersion)")
            Logger.data.debug("- 파일 크기: \(self.getRealmFileSize()) MB")
            Logger.data.debug("- UserProfile 개수: \(realm.objects(UserProfile.self).count)")
            Logger.data.debug("- FavoritePerformance 개수: \(realm.objects(FavoritePerformance.self).count)")
            Logger.data.debug("- ViewingRecord 개수: \(realm.objects(ViewingRecord.self).count)")
            Logger.data.debug("- RecentSearchKeyword 개수: \(realm.objects(RecentSearchKeyword.self).count)")
        } catch {
            Logger.data.error("Realm 디버그 정보 출력 실패: \(error)")
        }
    }
    
    // Realm 압축을 수행
    func compact() {
        do {
            let realm = try self.realm()
            try realm.writeCopy(toFile: realm.configuration.fileURL!)
            Logger.data.info("Realm 압축 완료")
        } catch {
            Logger.data.error("Realm 압축 실패: \(error.localizedDescription)")
        }
    }
    
    // 기본 사용자 프로필 초기화
    func initializeDefaultUser() throws {
        let realm = try self.realm()
        
        // 기존 유저가 있는지 확인
        if realm.objects(UserProfile.self).first != nil {
            Logger.data.info("기존 유저 프로필이 존재합니다")
            return
        }
        
        // 기본 유저 프로필 생성
        try realm.write {
            let defaultUser = UserProfile(nickname: "닉네임")
            realm.add(defaultUser, update: .modified)
            Logger.data.info("기본 유저 프로필 생성 완료")
        }
    }
}

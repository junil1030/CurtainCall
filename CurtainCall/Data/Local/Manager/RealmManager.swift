//
//  RealmManager.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import Foundation
import RealmSwift
import OSLog

final class RealmManager {
    
//    static let shared = RealmManager()
    
    // MARK: - Properties
    private var realm: Realm?
    
    // MARK: - Schema Version
    private enum RealmSchemaVersion: UInt64 {
        case initial = 1
        case changeGenreCode = 2
        
        static var current: UInt64 {
            return RealmSchemaVersion.changeGenreCode.rawValue
        }
    }
    
    // MARK: - Init
    private init() {
        configureRealm()
    }
    
    // MARK: - Configuration
    private func configureRealm() {
        let config = Realm.Configuration(
            schemaVersion: RealmSchemaVersion.current,
            migrationBlock: { migration, oldSchemaVersion in
                
                if oldSchemaVersion < RealmSchemaVersion.current {
                    self.performMigration(migration: migration, oldVersion: oldSchemaVersion)
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
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            realm = try Realm()
            Logger.data.info("Realm 초기화 성공")
            Logger.data.info("Realm 파일 경로: \(self.realm?.configuration.fileURL?.absoluteString ?? "Unknown")")
        } catch {
            Logger.data.error("Realm 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Migration
    private func performMigration(migration: Migration, oldVersion: UInt64) {
        Logger.data.info("마이그레이션 시작: v\(oldVersion) -> v\(RealmSchemaVersion.current)")
        
        // v1(initial) -> v2(changeGenreCode) 마이그레이션
        if oldVersion < RealmSchemaVersion.changeGenreCode.rawValue {
            migrateToChangeGenreCode(migration: migration)
        }
    }
    
    // MARK: - Migration Methods
    // v1 -> v2: ViewingRecord의 genre 필드를 DisplayName에서 Code로 변환
    private func migrateToChangeGenreCode(migration: Migration) {
        migration.enumerateObjects(ofType: ViewingRecord.className()) { oldObject, newObject in
            guard let oldObject = oldObject,
                  let newObject = newObject else { return }
            
            // 기존 장르 값 가져오기
            if let oldGenre = oldObject["genre"] as? String, !oldGenre.isEmpty {
                // DisplayName -> Code 변환
                let genreCode = self.convertDisplayNameToCode(oldGenre)
                newObject["genre"] = genreCode
                
                Logger.data.debug("장르 마이그레이션: \(oldGenre) -> \(genreCode)")
            }
        }
        
        Logger.data.info("v\(RealmSchemaVersion.initial.rawValue) -> v\(RealmSchemaVersion.changeGenreCode.rawValue) 마이그레이션 완료: ViewingRecord 장르 필드 Code 변환")
    }
    
    // MARK: - Migration Helper
    
    // DisplayName을 GenreCode로 변환
    private func convertDisplayNameToCode(_ displayName: String) -> String {
        // 1. 괄호 제거한 버전으로 매칭 시도
        let cleanedDisplayName = removeParenthesesContent(from: displayName)
        
        // 2. GenreCode에서 displayName으로 찾기
        if let genreCode = GenreCode.allCases.first(where: { $0.displayName == cleanedDisplayName }) {
            return genreCode.rawValue
        }
        
        // 3. 원본으로도 한번 더 시도 (이미 괄호가 없는 경우 대비)
        if let genreCode = GenreCode.allCases.first(where: { $0.displayName == displayName }) {
            return genreCode.rawValue
        }
        
        // 4. 이미 Code 형식인 경우 (GGGA, AAAA 등)
        if GenreCode(rawValue: displayName) != nil {
            return displayName
        }
        
        // 5. 매칭 실패 시 원본 반환
        Logger.data.warning("알 수 없는 장르 값: \(displayName)")
        return displayName
    }
    
    // 괄호와 괄호 안의 내용 제거
    private func removeParenthesesContent(from text: String) -> String {
        // 정규식으로 괄호와 내용 제거: "문자열(내용)" -> "문자열"
        return text.replacingOccurrences(of: "\\([^)]*\\)", with: "", options: .regularExpression)
    }
    
    // MARK: - Realm Instance
    func getRealm() throws -> Realm {
        if let realm = realm {
            return realm
        }
        
        let newRealm = try Realm()
        self.realm = newRealm
        return newRealm
    }
    
    // MARK: - Write Transaction
    func write(_ block: (Realm) throws -> Void) throws {
        let realm = try getRealm()
        
        if realm.isInWriteTransaction {
            try block(realm)
        } else {
            try realm.write {
                try block(realm)
            }
        }
    }
    
    // MARK: - Delete All
    func deleteAll() throws {
        let realm = try getRealm()
        try realm.write {
            realm.deleteAll()
        }
        Logger.data.warning("Realm 전체 데이터 삭제")
    }
    
    // MARK: - Compact
    func compact() {
        do {
            let realm = try getRealm()
            try realm.writeCopy(toFile: realm.configuration.fileURL!)
            Logger.data.info("Realm 압축 완료")
        } catch {
            Logger.data.error("Realm 압축 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Debug Info
    func printDebugInfo() {
        guard let realm = realm else {
            Logger.data.warning("Realm 인스턴스가 없습니다")
            return
        }
        
        Logger.data.debug("Realm 디버그 정보")
        Logger.data.debug("- 스키마 버전: \(realm.configuration.schemaVersion)")
        Logger.data.debug("- 파일 크기: \(self.getRealmFileSize()) MB")
        Logger.data.debug("- UserProfile 개수: \(realm.objects(UserProfile.self).count)")
        Logger.data.debug("- FavoritePerformance 개수: \(realm.objects(FavoritePerformance.self).count)")
        Logger.data.debug("- ViewingRecord 개수: \(realm.objects(ViewingRecord.self).count)")
        Logger.data.debug("- RecentSearchKeyword 개수: \(realm.objects(RecentSearchKeyword.self).count)")
    }
    
    private func getRealmFileSize() -> Double {
        guard let fileURL = realm?.configuration.fileURL else { return 0 }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? NSNumber {
                return fileSize.doubleValue / (1024 * 1024) // MB로 변환
            }
        } catch {
            Logger.data.error("파일 크기 확인 실패: \(error.localizedDescription)")
        }
        
        return 0
    }
}

// MARK: - User Profile
extension RealmManager {
    func initializeDefaultUser() throws {
        let realm = try getRealm()
        
        // 기존 유저가 있는지 확인
        if realm.objects(UserProfile.self).first != nil {
            Logger.data.info("기존 유저 프로필이 존재합니다")
            return
        }
        
        // 기본 유저 프로필 생성
        try write { realm in
            let defaultUser = UserProfile(nickname: "닉네임")
            realm.add(defaultUser, update: .modified)
            Logger.data.info("기본 유저 프로필 생성 완료")
        }
    }
}

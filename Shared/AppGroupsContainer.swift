//
//  AppGroupsContainer.swift
//  CurtainCall
//
//  Created by 서준일 on 12/8/25.
//

import Foundation

/// App Groups 컨테이너 관리
enum AppGroupsContainer {
    // MARK: - Constants

    /// App Groups 식별자
    static let identifier = "group.com.curtaincall.shared"

    /// App Groups 컨테이너 URL
    static var containerURL: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }

    // MARK: - Paths

    /// Realm Database 디렉토리
    static var realmDirectory: URL? {
        return containerURL?.appendingPathComponent("Database", isDirectory: true)
    }

    /// Realm 파일 경로
    static var realmFileURL: URL? {
        return realmDirectory?.appendingPathComponent("default.realm")
    }

    /// CustomImageCache 디렉토리
    static var imageCacheDirectory: URL? {
        return containerURL?.appendingPathComponent("Library/Caches/CustomImageCache", isDirectory: true)
    }

    /// UserDefaults Suite
    static var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: identifier)
    }

    // MARK: - Helper Methods

    /// 디렉토리 생성
    static func createDirectoriesIfNeeded() {
        guard let realmDir = realmDirectory,
              let cacheDir = imageCacheDirectory else {
            return
        }

        let fileManager = FileManager.default

        // Realm 디렉토리
        if !fileManager.fileExists(atPath: realmDir.path) {
            try? fileManager.createDirectory(at: realmDir, withIntermediateDirectories: true)
        }

        // Image Cache 디렉토리
        if !fileManager.fileExists(atPath: cacheDir.path) {
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
    }
}

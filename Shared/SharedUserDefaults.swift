//
//  SharedUserDefaults.swift
//  CurtainCall
//
//  Created by 서준일 on 12/8/25.
//

import Foundation

/// App Groups 공유 UserDefaults
final class SharedUserDefaults {
    // MARK: - Singleton

    static let shared = SharedUserDefaults()

    // MARK: - Properties

    private let userDefaults: UserDefaults

    // MARK: - Keys

    enum Key: String {
        case lastWidgetUpdate = "lastWidgetUpdateDate"
        case favoriteCount = "favoriteCount"
        case recordCount = "recordCount"
        case widgetDataCache = "widgetDataCache"
    }

    // MARK: - Initialization

    private init() {
        if let defaults = AppGroupsContainer.userDefaults {
            self.userDefaults = defaults
        } else {
            // Fallback: 기본 UserDefaults
            self.userDefaults = UserDefaults.standard
        }
    }

    // MARK: - Public Methods

    /// 값 저장
    func set<T>(_ value: T, forKey key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    /// 값 가져오기
    func get<T>(forKey key: Key) -> T? {
        return userDefaults.value(forKey: key.rawValue) as? T
    }

    /// 값 삭제
    func remove(forKey key: Key) {
        userDefaults.removeObject(forKey: key.rawValue)
    }

    /// String 저장
    func setString(_ value: String, forKey key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    /// String 가져오기
    func getString(forKey key: Key) -> String? {
        return userDefaults.string(forKey: key.rawValue)
    }

    /// Int 저장
    func setInt(_ value: Int, forKey key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    /// Int 가져오기
    func getInt(forKey key: Key) -> Int {
        return userDefaults.integer(forKey: key.rawValue)
    }

    /// Bool 저장
    func setBool(_ value: Bool, forKey key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    /// Bool 가져오기
    func getBool(forKey key: Key) -> Bool {
        return userDefaults.bool(forKey: key.rawValue)
    }

    /// Date 저장
    func setDate(_ value: Date, forKey key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    /// Date 가져오기
    func getDate(forKey key: Key) -> Date? {
        return userDefaults.object(forKey: key.rawValue) as? Date
    }

    /// 동기화
    func synchronize() {
        userDefaults.synchronize()
    }
}

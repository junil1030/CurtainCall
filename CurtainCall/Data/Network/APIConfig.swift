//
//  APIConfig.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation
import OSLog

enum APIConfig {
    private static func validatedValue(for key: String) -> String {
        guard let rawValue = Bundle.main.infoDictionary?[key] as? String else {
            Logger.config.error("\(key)가 Info.plist에 없습니다.")
            fatalError("\(key)가 Info.plist에 없습니다.")
        }

        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !value.isEmpty else {
            Logger.config.error("\(key) 값이 비어있습니다.")
            fatalError("\(key) 값이 비어있습니다.")
        }

        // Build setting 치환이 실패하면 $(KEY_NAME) 형태 문자열이 그대로 남는다.
        guard !value.contains("$(") else {
            Logger.config.error("\(key) 값 치환에 실패했습니다. xcconfig 주입 여부를 확인하세요.")
            fatalError("\(key) 값 치환에 실패했습니다.")
        }

        return value
    }

    // MARK: - Base Configuration
    static var kopisAPIKey: String {
        let key = validatedValue(for: "KOPIS_API_KEY")
        Logger.config.info("Key 로드 완료")
        return key
    }
    
    static var baseURL: String {
        let url = validatedValue(for: "KOPIS_BASE_URL")

        guard url.hasPrefix("http://") || url.hasPrefix("https://") else {
            Logger.config.error("KOPIS Base URL 형식이 올바르지 않습니다: \(url)")
            fatalError("KOPIS Base URL 형식이 올바르지 않습니다.")
        }
        
        let normalizedURL = url.hasSuffix("/") ? url : "\(url)/"
        Logger.config.info("Base URL 로드 완료: \(normalizedURL)")
        return normalizedURL
    }
}

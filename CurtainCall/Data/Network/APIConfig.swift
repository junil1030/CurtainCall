//
//  APIConfig.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation
import OSLog

enum APIConfig {
    // MARK: - Base Configuration
    static var kopisAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["KOPIS_API_KEY"] as? String, !key.isEmpty else {
            Logger.config.warning("KOPIS_API_KEY가 설정되지 않았습니다.")
            fatalError("KOPIS_API_KEY가 설정되지 않았습니다.")
        }
        Logger.config.info("Key 로드 완료")
        return key
    }
    
    static var baseURL: String {
        guard let url = Bundle.main.infoDictionary?["KOPIS_BASE_URL"] as? String,
              !url.isEmpty else {
            Logger.config.error("KOPIS Base URL이 설정되지 않았습니다.")
            fatalError("KOPIS Base URL이 설정되지 않았습니다.")
        }
        
        Logger.config.info("Base URL 로드 완료: \(url)")
        return url
    }
}

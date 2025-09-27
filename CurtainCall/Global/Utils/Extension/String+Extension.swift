//
//  String+Extension.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation

extension String {
    // HTTP URL을 HTTPS로 변환
    var toHTTPS: String {
        if hasPrefix("http://") {
            return replacingOccurrences(of: "http://", with: "https://")
        }
        return self
    }
    
    // 안전한 이미지 URL 반환 (HTTPS 변환 + 유효성 검사)
    var safeImageURL: URL? {
        let httpsURLString = self.toHTTPS
        return URL(string: httpsURLString)
    }
}

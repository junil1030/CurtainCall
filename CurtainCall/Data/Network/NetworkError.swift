//
//  NetworkError.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case noInternetConnection
    case timeout
    case connectionFailed
    case serverError(Int)
    case invalidResponse
    case parsingFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "인터넷 연결을 확인해주세요."
        case .timeout:
            return "요청 시간이 초과되었습니다."
        case .connectionFailed:
            return "서버 연결에 실패했습니다."
        case .serverError(let code):
            return "서버 오류가 발생했습니다. (코드: \(code))"
        case .invalidResponse:
            return "올바르지 않은 응답입니다."
        case .parsingFailed:
            return "데이터 파싱에 실패했습니다."
        case .unknown(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
}

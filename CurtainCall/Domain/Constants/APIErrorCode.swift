//
//  APIErrorCode.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation

enum APIErrorCode: String, CaseIterable {
    case normal = "00"
    case invalidParameter = "01"
    case invalidServiceKey = "02"
    case databaseError = "03"
    case noData = "04"
    case dateLimitExceeded = "05"
    case countLimitExceeded = "06"
    case systemError = "99"
    
    var description: String {
        switch self {
        case .normal:
            return "정상 서비스"
        case .invalidParameter:
            return "잘못된 요청 파라미터"
        case .invalidServiceKey:
            return "등록되지 않은 서비스 키"
        case .databaseError:
            return "데이터베이스 오류"
        case .noData:
            return "조회된 데이터가 없음"
        case .dateLimitExceeded:
            return "최대 31일까지 조회 가능"
        case .countLimitExceeded:
            return "최대 조회수는 100건까지 가능"
        case .systemError:
            return "시스템 오류 발생"
        }
    }
    
    var userFriendlyMessage: String {
        switch self {
        case .normal:
            return "정상"
        case .invalidParameter:
            return "잘못된 요청입니다."
        case .invalidServiceKey:
            return "서비스 키 오류입니다."
        case .databaseError:
            return "잠시 후 다시 시도해주세요."
        case .noData:
            return "검색 결과가 없습니다."
        case .dateLimitExceeded:
            return "최대 31일까지 조회할 수 있습니다."
        case .countLimitExceeded:
            return "최대 100건까지 조회할 수 있습니다."
        case .systemError:
            return "잠시 후 다시 시도해주세요."
        }
    }
    
    var isUserError: Bool {
        switch self {
        case .invalidParameter, .dateLimitExceeded, .countLimitExceeded:
            return true
        default:
            return false
        }
    }
    
    var isServerError: Bool {
        switch self {
        case .databaseError, .systemError:
            return true
        default:
            return false
        }
    }
}

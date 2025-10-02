//
//  RealmError.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import Foundation

enum RealmError: Error {
    case initializationFailed
    case objectNotFound
    case invalidData
    case writeFailed
    case deleteFailed
    case migrationFailed
    
    var localizedDescription: String {
        switch self {
        case .initializationFailed:
            return "Realm 초기화에 실패했습니다"
        case .objectNotFound:
            return "객체를 찾을 수 없습니다"
        case .invalidData:
            return "유효하지 않은 데이터입니다"
        case .writeFailed:
            return "데이터 저장에 실패했습니다"
        case .deleteFailed:
            return "데이터 삭제에 실패했습니다"
        case .migrationFailed:
            return "데이터베이스 마이그레이션에 실패했습니다"
        }
    }
    
    var userFriendlyMessage: String {
        switch self {
        case .initializationFailed:
            return "앱을 다시 시작해주세요"
        case .objectNotFound:
            return "요청하신 데이터를 찾을 수 없습니다"
        case .invalidData:
            return "데이터 형식이 올바르지 않습니다"
        case .writeFailed, .deleteFailed:
            return "잠시 후 다시 시도해주세요"
        case .migrationFailed:
            return "앱을 재설치해주세요"
        }
    }
}

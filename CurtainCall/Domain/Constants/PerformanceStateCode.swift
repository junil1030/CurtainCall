//
//  PerformanceStateCode.swift
//  CurtainCall
//
//  Created by 서준일 on 9/26/25.
//

enum PerformanceStateCode: String, CaseIterable {
    // 변수명: prfstate
    // 필드명: prtstate
    case scheduled  = "01"
    case during     = "02"
    case completed  = "03"
    
    var displayName: String {
        switch self {
        case .scheduled: return "공연예정"
        case .during:    return "공연중"
        case .completed: return "공연완료"
        }
    }
}

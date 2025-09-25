//
//  DateTypeCode.swift
//  CurtainCall
//
//  Created by 서준일 on 9/26/25.
//

enum DateTypeCode: String, CaseIterable {
    // 변수명: ststype
    case month = "month"
    case week  = "week"
    case day   = "day"
    
    var displayName: String {
        switch self {
        case .month: return "월별"
        case .week:  return "주별"
        case .day:   return "일별"
        }
    }
}

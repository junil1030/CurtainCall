//
//  FacilitiesCode.swift
//  CurtainCall
//
//  Created by 서준일 on 9/26/25.
//

enum FacilitiesCode: String, CaseIterable {
    // 변수명: fcltychartr
    // 필드명: fcltychartr
    case centralGovernment  = "1"
    case artCenter          = "2"
    case otherPublic        = "3"
    case daehangno          = "4"
    case privateOther       = "5"
    case otherOverseas      = "6"
    case otherNonTheater    = "7"
    
    var displayName: String {
        switch self {
        case .centralGovernment: return "중앙정부"
        case .artCenter:         return "문예회관"
        case .otherPublic:       return "기타(공공)"
        case .daehangno:         return "대학로"
        case .privateOther:      return "민간(대학로 외)"
        case .otherOverseas:     return "기타(해외등)"
        case .otherNonTheater:   return "기타(비공연장)"
        }
    }
}

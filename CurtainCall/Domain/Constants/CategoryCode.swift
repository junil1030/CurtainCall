//
//  CategoryCode.swift
//  CurtainCall
//
//  Created by 서준일 on 9/26/25.
//

enum CategoryCode: String, CaseIterable {
    // 변수명: catecode
    // 필드명: cate
    case play         = "AAAA"
    case musical      = "GGGA"
    case classic      = "CCCA"
    case koreanMusic  = "CCCC"
    case popularMusic = "CCCD"
    case dance        = "BBBC"
    case popularDance = "BBBR"
    case circusMagic  = "EEEB"
    case complex      = "EEEA"
    case kid          = "KID"
    case openRun      = "OPEN"
    
    var displayName: String {
        switch self {
        case .play:         return "연극"
        case .musical:      return "뮤지컬"
        case .classic:      return "서양음악"
        case .koreanMusic:  return "한국음악"
        case .popularMusic: return "대중음악"
        case .dance:        return "무용"
        case .popularDance: return "대중무용"
        case .circusMagic:  return "서커스/마술"
        case .complex:      return "복합"
        case .kid:          return "아동"
        case .openRun:      return "오픈런"
        }
    }
}

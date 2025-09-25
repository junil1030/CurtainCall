//
//  GenreCode.swift
//  CurtainCall
//
//  Created by 서준일 on 9/26/25.
//

enum GenreCode: String, CaseIterable {
    // 변수명: shcate
    // 필드명: genrenm
    case play           = "AAAA"
    case dance          = "BBBC"
    case popularDance   = "BBBE"
    case classic        = "CCCA"
    case koreanMusic    = "CCCC"
    case popularMusic   = "CCCD"
    case complex        = "EEEA"
    case circus_Magic   = "EEEB"
    case musical        = "GGGA"
    
    var displayName: String {
        switch self {
        case .play:         return "연극"
        case .dance:        return "무용(서양/한국무용"
        case .popularDance: return "대중무용"
        case .classic:      return "서양음악(클래식)"
        case .koreanMusic:  return "한국음악(국악)"
        case .popularMusic: return "대중음악"
        case .complex:      return "복합공연"
        case .circus_Magic: return "서커스/마술"
        case .musical:      return "뮤지컬"
        }
    }
}

//
//  AreaCode.swift
//  CurtainCall
//
//  Created by 서준일 on 9/26/25.
//

enum AreaCode: String, CaseIterable {
    // 변수명: area
    // 필드명: area
    case seoul      = "11"
    case incheon    = "28"
    case daejeon    = "30"
    case daegu      = "27"
    case gwangju    = "29"
    case busan      = "26"
    case ulsan      = "31"
    case sejong     = "36"
    case gyeonggi   = "41"
    case chungbuk   = "43"
    case chungnam   = "44"
    case jeonbuk    = "45"
    case jeonnam    = "46"
    case gyeongbuk  = "47"
    case gyeongnam  = "48"
    case gangwon    = "51"
    case jeju       = "50"
    case daehangno  = "UNI"
    
    var displayName: String {
        switch self {
        case .seoul:     return "서울"
        case .incheon:   return "인천"
        case .daejeon:   return "대전"
        case .daegu:     return "대구"
        case .gwangju:   return "광주"
        case .busan:     return "부산"
        case .ulsan:     return "울산"
        case .sejong:    return "세종"
        case .gyeonggi:  return "경기"
        case .chungbuk:  return "충북"
        case .chungnam:  return "충남"
        case .jeonbuk:   return "전북"
        case .jeonnam:   return "전남"
        case .gyeongbuk: return "경북"
        case .gyeongnam: return "경남"
        case .gangwon:   return "강원"
        case .jeju:      return "제주"
        case .daehangno: return "대학로"
        }
    }
    
    static func from(displayName: String) -> AreaCode? {
        return AreaCode.allCases.first { $0.displayName == displayName }
    }

}

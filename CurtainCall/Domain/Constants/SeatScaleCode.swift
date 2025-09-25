//
//  SeatScaleCode.swift
//  CurtainCall
//
//  Created by 서준일 on 9/26/25.
//

enum SeatScaleCode: String, CaseIterable {
    // 변수명: srchseatscale
    // 필드명: srchseatscale
    case unknown    = "0"
    case under300   = "100"
    case under500   = "300"
    case under1000  = "500"
    case under5000  = "1000"
    case under10000 = "5000"
    case over10000  = "10000"
    
    var displayName: String {
        switch self {
        case .unknown:    return "0석(미상)"
        case .under300:   return "1~300석 미만"
        case .under500:   return "300~500석 미만"
        case .under1000:  return "500~1000석 미만"
        case .under5000:  return "1000~5000석 미만"
        case .under10000: return "5000~10000석 미만"
        case .over10000:  return "10000석 이상"
        }
    }
}

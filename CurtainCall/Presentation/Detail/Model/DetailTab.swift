//
//  DetailTab.swift
//  CurtainCall
//
//  Created by 서준일 on 10/21/25.
//

import Foundation

enum DetailTab: Int, CaseIterable {
    case info
    case booking
    case cast
    case production
    
    var title: String {
        switch self {
        case .info:
            return "공연정보"
        case .booking:
            return "예매정보"
        case .cast:
            return "출연진"
        case .production:
            return "제작정보"
        }
    }
}

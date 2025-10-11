//
//  RatingFilterOption.swift
//  CurtainCall
//
//  Created by 서준일 on 10/10/25.
//

import Foundation

enum RatingFilterOption: Int, CaseIterable {
    case all = 0
    case five = 5
    case four = 4
    case three = 3
    case two = 2
    case one = 1
    
    var displayName: String {
        switch self {
        case .all:
            return "전체"
        case .five:
            return "5점"
        case .four:
            return "4점"
        case .three:
            return "3점"
        case .two:
            return "2점"
        case .one:
            return "1점"
        }
    }
    
    var ratingValue: Int? {
        switch self {
        case .all:
            return nil
        default:
            return self.rawValue
        }
    }
    
    // 선택된 필터 옵션들로 레코드를 필터링하는 메서드
    static func filter(_ records: [ViewingRecordDTO], with options: [RatingFilterOption]) -> [ViewingRecordDTO] {
        // 전체가 선택되었거나 아무것도 선택되지 않은 경우
        if options.isEmpty || options.contains(.all) {
            return records
        }
        
        // 선택된 평점들
        let selectedRatings = options.compactMap { $0.ratingValue }
        
        // 선택된 평점에 해당하는 레코드만 필터링
        return records.filter { record in
            selectedRatings.contains(record.rating)
        }
    }
}

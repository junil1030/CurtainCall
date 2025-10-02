//
//  DateFormtter+Extension.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation

extension DateFormatter {
    
    // MARK: - Shared Instance
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
    
    enum FormatType {
        case kopisAPI           // yyyyMMdd
        case dateWithWeekday    // yyyy.MM.dd(E)
        case time24Hour         // HH:mm
        
        var pattern: String {
            switch self {
            case .kopisAPI:
                return "yyyyMMdd"
            case .dateWithWeekday:
                return "yyyy.MM.dd(E)"
            case .time24Hour:
                return "HH:mm"
            }
        }
    }
    
    static func string(from date: Date, format: FormatType) -> String {
        shared.dateFormat = format.pattern
        return shared.string(from: date)
    }
}

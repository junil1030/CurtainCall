//
//  Date+Extension.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation

extension Date {
    var toKopisAPIFormatt: String {
        return DateFormatter.kopisAPIFormat.string(from: self)
    }
    
    // MARK: - 날짜 계산
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
    }
    
    /// 지정된 일수만큼 이전 날짜
    func daysBefore(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }
    
    /// 지정된 일수만큼 이후 날짜
    func daysAfter(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
}

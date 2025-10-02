//
//  Date+Extension.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation

extension Date {
    var toKopisAPIFormatt: String {
        return DateFormatter.string(from: self, format: .kopisAPI)
    }
    
    var toDateWithWeekday: String {
        return DateFormatter.string(from: self, format: .dateWithWeekday)
    }
    
    var toTime24Hour: String {
        return DateFormatter.string(from: self, format: .time24Hour)
    }
    
    // MARK: - 날짜 계산
    /// API 데이터 업데이트 시간을 고려한 어제 날짜
    /// 오전 12시 이전: 2일 전 데이터, 12시 이후: 1일 전 데이터
    var yesterday: Date {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: self)
        
        // 오전 12시(정오) 이전이면 2일 전, 이후면 1일 전
        let daysToSubtract = currentHour < 12 ? 2 : 1
        
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: self) ?? self
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

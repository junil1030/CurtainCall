//
//  DateCalculator.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

struct DateCalculator {
    
    private static let calendar = Calendar.current
    
    // MARK: - 주간 (이번 주)
    
    // 이번 주 월요일 00:00:00 반환
    static func startOfThisWeek(from date: Date = Date()) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        // weekday: 1(일요일) ~ 7(토요일)
        // 월요일까지의 일수 계산: 일요일이면 -6일, 월요일이면 0일
        let daysFromMonday = weekday == 1 ? -6 : -(weekday - 2)
        
        guard let monday = calendar.date(byAdding: .day, value: daysFromMonday, to: date) else {
            return startOfDay(date)
        }
        
        return startOfDay(monday)
    }
    
    // 이번 주 일요일 23:59:59 반환
    static func endOfThisWeek(from date: Date = Date()) -> Date {
        let monday = startOfThisWeek(from: date)
        guard let sunday = calendar.date(byAdding: .day, value: 6, to: monday) else {
            return endOfDay(date)
        }
        
        return endOfDay(sunday)
    }
    
    // 지난 주 월요일 00:00:00 반환
    static func startOfLastWeek(from date: Date = Date()) -> Date {
        let thisWeekMonday = startOfThisWeek(from: date)
        guard let lastWeekMonday = calendar.date(byAdding: .day, value: -7, to: thisWeekMonday) else {
            return thisWeekMonday
        }
        
        return lastWeekMonday
    }
    
    // 지난 주 일요일 23:59:59 반환
    static func endOfLastWeek(from date: Date = Date()) -> Date {
        let lastWeekMonday = startOfLastWeek(from: date)
        guard let lastWeekSunday = calendar.date(byAdding: .day, value: 6, to: lastWeekMonday) else {
            return endOfDay(lastWeekMonday)
        }
        
        return endOfDay(lastWeekSunday)
    }
    
    // MARK: - 월간 (이번 달)
    
    // 이번 달 1일 00:00:00 반환
    static func startOfThisMonth(from date: Date = Date()) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDay = calendar.date(from: components) else {
            return startOfDay(date)
        }
        
        return firstDay
    }
    
    // 이번 달 마지막 날 23:59:59 반환
    static func endOfThisMonth(from date: Date = Date()) -> Date {
        let firstDay = startOfThisMonth(from: date)
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDay),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: nextMonth) else {
            return endOfDay(date)
        }
        
        return endOfDay(lastDay)
    }
    
    // 지난 달 1일 00:00:00 반환
    static func startOfLastMonth(from date: Date = Date()) -> Date {
        let thisMonthFirstDay = startOfThisMonth(from: date)
        guard let lastMonthFirstDay = calendar.date(byAdding: .month, value: -1, to: thisMonthFirstDay) else {
            return thisMonthFirstDay
        }
        
        return lastMonthFirstDay
    }
    
    // 지난 달 마지막 날 23:59:59 반환
    static func endOfLastMonth(from date: Date = Date()) -> Date {
        let thisMonthFirstDay = startOfThisMonth(from: date)
        guard let lastDay = calendar.date(byAdding: .day, value: -1, to: thisMonthFirstDay) else {
            return endOfDay(date)
        }
        
        return endOfDay(lastDay)
    }
    
    // MARK: - 연간 (올해)
    
    // 올해 1월 1일 00:00:00 반환
    static func startOfThisYear(from date: Date = Date()) -> Date {
        let year = calendar.component(.year, from: date)
        let components = DateComponents(year: year, month: 1, day: 1)
        
        guard let firstDay = calendar.date(from: components) else {
            return startOfDay(date)
        }
        
        return firstDay
    }
    
    // 올해 12월 31일 23:59:59 반환
    static func endOfThisYear(from date: Date = Date()) -> Date {
        let year = calendar.component(.year, from: date)
        let components = DateComponents(year: year, month: 12, day: 31)
        
        guard let lastDay = calendar.date(from: components) else {
            return endOfDay(date)
        }
        
        return endOfDay(lastDay)
    }
    
    // 작년 1월 1일 00:00:00 반환
    static func startOfLastYear(from date: Date = Date()) -> Date {
        let thisYearFirstDay = startOfThisYear(from: date)
        guard let lastYearFirstDay = calendar.date(byAdding: .year, value: -1, to: thisYearFirstDay) else {
            return thisYearFirstDay
        }
        
        return lastYearFirstDay
    }
    
    // 작년 12월 31일 23:59:59 반환
    static func endOfLastYear(from date: Date = Date()) -> Date {
        let thisYearFirstDay = startOfThisYear(from: date)
        guard let lastDay = calendar.date(byAdding: .day, value: -1, to: thisYearFirstDay) else {
            return endOfDay(date)
        }
        
        return endOfDay(lastDay)
    }
    
    // MARK: - 월 평균 계산용
    
    // 올해 1월부터 현재 월까지의 개월 수 반환 (1 ~ 12)
    static func monthsElapsedThisYear(from date: Date = Date()) -> Int {
        return calendar.component(.month, from: date)
    }
    
    // MARK: - Helper Methods
    
    // 해당 날짜의 00:00:00 반환
    private static func startOfDay(_ date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    // 해당 날짜의 23:59:59 반환
    private static func endOfDay(_ date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        
        guard let endDate = calendar.date(byAdding: components, to: startOfDay(date)) else {
            return date
        }
        
        return endDate
    }
}

// MARK: - StatsPeriod Extension
extension DateCalculator {
    
    // 기간별 시작일/종료일 반환
    static func dateRange(for period: StatsPeriod, from date: Date = Date()) -> (start: Date, end: Date) {
        switch period {
        case .weekly:
            return (startOfThisWeek(from: date), endOfThisWeek(from: date))
        case .monthly:
            return (startOfThisMonth(from: date), endOfThisMonth(from: date))
        case .yearly:
            return (startOfThisYear(from: date), endOfThisYear(from: date))
        }
    }
    
    // 이전 기간의 시작일/종료일 반환 (변화량 계산용)
    static func previousDateRange(for period: StatsPeriod, from date: Date = Date()) -> (start: Date, end: Date) {
        switch period {
        case .weekly:
            return (startOfLastWeek(from: date), endOfLastWeek(from: date))
        case .monthly:
            return (startOfLastMonth(from: date), endOfLastMonth(from: date))
        case .yearly:
            return (startOfLastYear(from: date), endOfLastYear(from: date))
        }
    }
}

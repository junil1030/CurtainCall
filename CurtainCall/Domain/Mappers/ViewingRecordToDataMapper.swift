//
//  ViewingRecordToDataMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/5/25.
//

import Foundation

struct ViewingRecordToDataMapper {
    
    static func map(from record: ViewingRecord) -> ViewingRecordData {
        // viewingDate에서 날짜와 시간 분리
        let calendar = Calendar.current
        
        // 날짜 부분 (시간은 00:00:00)
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: record.viewingDate)
        let viewingDate = calendar.date(from: dateComponents) ?? record.viewingDate
        
        // 시간 부분은 원본 Date 그대로 사용 (DatePicker가 시간만 추출)
        let viewingTime = record.viewingDate
        
        return ViewingRecordData(
            viewingDate: viewingDate,
            viewingTime: viewingTime,
            companion: record.companion,
            seat: record.seat,
            rating: record.rating,
            review: record.memo
        )
    }
}


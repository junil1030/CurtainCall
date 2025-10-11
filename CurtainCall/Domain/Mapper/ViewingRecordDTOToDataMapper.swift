//
//  ViewingRecordDTOToDataMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 10/11/25.
//

import Foundation

struct ViewingRecordDTOToDataMapper {
    
    static func map(from dto: ViewingRecordDTO) -> ViewingRecordData {
        // viewingDate에서 날짜와 시간 분리
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: dto.viewingDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: dto.viewingDate)
        
        let date = calendar.date(from: dateComponents) ?? dto.viewingDate
        let time = calendar.date(from: timeComponents) ?? dto.viewingDate
        
        return ViewingRecordData(
            viewingDate: date,
            viewingTime: time,
            companion: dto.companion,
            seat: dto.seat,
            rating: dto.rating,
            review: dto.memo
        )
    }
}

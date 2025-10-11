//
//  RecordSortType.swift
//  CurtainCall
//
//  Created by 서준일 on 10/10/25.
//

import Foundation

enum RecordSortType: String, CaseIterable {
    case latest = "최신순"
    case oldest = "오래된순"
    case ratingDesc = "평점 높은순"
    case ratingAsc = "평점 낮은순"
    case title = "제목순"
    
    var displayName: String {
        return self.rawValue
    }
    
    // ViewingRecordDTO 배열을 정렬하는 메서드
    func sort(_ records: [ViewingRecordDTO]) -> [ViewingRecordDTO] {
        switch self {
        case .latest:
            return records.sorted { $0.viewingDate > $1.viewingDate }
        case .oldest:
            return records.sorted { $0.viewingDate < $1.viewingDate }
        case .ratingDesc:
            return records.sorted { $0.rating > $1.rating }
        case .ratingAsc:
            return records.sorted { $0.rating < $1.rating }
        case .title:
            return records.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        }
    }
}

//
//  SearchResultMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import Foundation

struct SearchResultMapper {
    static func map(from dto: SearchItemDTO) -> SearchResult {
        return SearchResult(
            id: dto.mt20id,
            title: dto.prfnm,
            startDate: dto.prfpdfrom ?? "정보없음",
            endDate: dto.prfpdto ?? "정보없음",
            location: dto.fcltynm ?? "정보없음",
            posterURL: dto.poster ?? "정보없음",
            area: dto.area ?? "정보없음",
            genre: dto.genrenm ?? "정보없음",
            isOpenRun: dto.openrun?.uppercased() == "N",
            state: dto.prfstate ?? "정보없음"
        )
    }
    
    static func map(from dtos: [SearchItemDTO]) -> [SearchResult] {
        return dtos.map { map(from: $0) }
    }
}

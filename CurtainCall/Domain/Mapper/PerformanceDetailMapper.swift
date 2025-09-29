//
//  PerformanceDetailMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import Foundation

struct PerformanceDetailMapper {
    static func map(from dto: PerformanceDetailDTO) -> PerformanceDetail {
        
        let bookingSites = dto.relates?.relate.map { relateDTO in
            BookingSite(name: relateDTO.relatenm, url: relateDTO.relateurl)
        } ?? []
        
        let detailPosterURL = dto.styurls?.styurl ?? dto.poster
        
        return PerformanceDetail(
            id: dto.mt20id,
            title: dto.prfnm,
            startDate: dto.prfpdfrom,
            endDate: dto.prfpdto,
            location: dto.fcltynm,
            posterURL: dto.poster,
            detailPosterURL: detailPosterURL,
            cast: dto.prfcast,
            bookingSites: bookingSites
        )
    }
    
    static func map(from dtos: [PerformanceDetailDTO]) -> [PerformanceDetail] {
        return dtos.map { map(from: $0) }
    }
}

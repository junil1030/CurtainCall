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
        
        // MARK: - 변경 필요
        let detailPosterURL = dto.styurls?.styurl ?? []
        
        let castString = dto.prfcast ?? "출연진에 대한 정보가 없어요"
        let castArray = castString.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        return PerformanceDetail(
            id: dto.mt20id,
            title: dto.prfnm,
            startDate: dto.prfpdfrom,
            endDate: dto.prfpdto,
            area: dto.area,
            location: dto.fcltynm,
            genre: dto.genrenm,         // 장르 매핑 추가
            posterURL: dto.poster ?? "",
            detailPosterURL: detailPosterURL,
            cast: castArray,
            bookingSites: bookingSites
        )
    }
    
    static func map(from dtos: [PerformanceDetailDTO]) -> [PerformanceDetail] {
        return dtos.map { map(from: $0) }
    }
}

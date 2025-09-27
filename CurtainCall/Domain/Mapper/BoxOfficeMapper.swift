//
//  BoxOfficeMapper.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation

struct BoxOfficeMapper {
    static func map(from dto: BoxOfficeItemDTO) -> BoxOffice {
        return BoxOffice(rank: dto.rnum, title: dto.prfnm, location: dto.prfplcnm, posterURL: dto.poster, perfomanceID: dto.mt20id)
    }
    
    static func map(from dtos: [BoxOfficeItemDTO]) -> [BoxOffice] {
        return dtos.map { map(from: $0) }
    }
}

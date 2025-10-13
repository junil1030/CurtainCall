//
//  BoxOfficeResponseDTO.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Parsely

struct BoxOfficeResponseDTO: ParselyType {
    let boxofs: BoxOfficeListDTO
}

struct BoxOfficeListDTO: ParselyType {
    let boxof: [BoxOfficeItemDTO]
}

struct BoxOfficeItemDTO: ParselyType {
    let cate: String     // 장르
    let rnum: String     // 순위
    let prfnm: String    // 공연명
    let prfpd: String    // 공연기간
    let prfdtcnt: String // 상연횟수
    let area: String     // 지역
    let prfplcnm: String // 공연장
    let seatcnt: String  // 좌석수
    let poster: String   // 포스터 이미지
    let mt20id: String   // 공연ID
}

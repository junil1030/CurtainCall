//
//  PerformanceDetailResponseDTO.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import Parsely

// MARK: - Response Root
struct PerformanceDetailResponseDTO: ParselyType {
    let dbs: PerformanceDetailDatabaseDTO
}

// MARK: - Database
struct PerformanceDetailDatabaseDTO: ParselyType {
    let db: PerformanceDetailDTO
}

// MARK: - Performance Detail
struct PerformanceDetailDTO: ParselyType {
    let mt20id: String          // 공연ID
    let prfnm: String           // 공연명
    let prfpdfrom: String?       // 공연시작일
    let prfpdto: String?         // 공연종료일
    let fcltynm: String?         // 공연장명
    let prfcast: String?         // 공연출연진
    let prfcrew: String?         // 공연제작진
    let prfruntime: String?      // 공연런타임
    let prfage: String?          // 관람연령
    let entrpsnm: String?        // 제작사
    let entrpsnmP: String?       // 기획제작사
    let entrpsnmA: String?       // 주최
    let entrpsnmH: String?       // 주관
    let entrpsnmS: String?       // 후원
    let pcseguidance: String?    // 티켓가격
    let poster: String?          // 포스터 이미지
    let sty: String?             // 줄거리
    let area: String?            // 지역
    let genrenm: String?         // 장르
    let openrun: String?         // 오픈런 여부 (Y/N)
    let visit: String?           // 방문여부 (Y/N)
    let child: String?           // 아동청소년관람여부 (Y/N)
    let daehakro: String?        // 대학로여부 (Y/N)
    let festival: String?        // 페스티벌여부 (Y/N)
    let musicallicense: String?  // 뮤지컬라이선스 (Y/N)
    let musicalcreate: String?   // 창작뮤지컬 (Y/N)
    let updatedate: String?      // 업데이트일자
    let prfstate: String?        // 공연상태
    let mt10id: String?          // 공연시설ID
    let dtguidance: String?      // 공연시간
    let styurls: StyleImageListDTO?  // 소개이미지 목록
    let relates: RelatedLinkListDTO? // 관련링크 목록
}

// MARK: - Style Images
struct StyleImageListDTO: ParselyType {
    let styurl: [String]        // 소개이미지 URL 배열
}

// MARK: - Related Links
struct RelatedLinkListDTO: ParselyType {
    let relate: [RelatedLinkDTO]
}

struct RelatedLinkDTO: ParselyType {
    let relatenm: String        // 관련링크명
    let relateurl: String       // 관련링크 URL
}

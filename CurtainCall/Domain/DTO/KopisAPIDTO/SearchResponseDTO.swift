//
//  SearchResponseDTO.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import Parsely

// MARK: - Response Root
struct SearchResponseDTO: ParselyType {
    let dbs: SearchDatabaseDTO
}

// MARK: - Database
struct SearchDatabaseDTO: ParselyType {
    let db: [SearchItemDTO]
}

// MARK: - Search Item
struct SearchItemDTO: ParselyType {
    let mt20id: String          // 공연ID (필수)
    let prfnm: String           // 공연명 (필수)
    let prfpdfrom: String?      // 공연시작일
    let prfpdto: String?        // 공연종료일
    let fcltynm: String?        // 공연장명
    let poster: String?         // 포스터 이미지
    let area: String?           // 지역
    let genrenm: String?        // 장르
    let openrun: String?        // 오픈런 여부 (Y/N)
    let prfstate: String?       // 공연상태
}

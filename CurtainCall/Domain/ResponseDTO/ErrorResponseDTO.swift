//
//  ErrorResponseDTO.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Parsely

struct ErrorResponseDTO: ParselyType {
    let dbs: ErrorDatabaseDTO
}

struct ErrorDatabaseDTO: ParselyType {
    let db: ErrorDetailDTO
}

struct ErrorDetailDTO: ParselyType {
    let returncode: String
    let errmsg: String
    let responsetime: String
    
    var errorCode: APIErrorCode? {
        return APIErrorCode(rawValue: returncode)
    }
    
    var isError: Bool {
        return returncode != "00"
    }
}

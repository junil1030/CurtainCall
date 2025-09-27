//
//  APIRouter.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation
import Alamofire

enum APIRouter {
    case boxOffice(startDate: String, endDate: String, genre: GenreCode?, area: AreaCode?)
}

extension APIRouter {
    var path: String {
        switch self {
        case .boxOffice:
            return "boxoffice"
        }
    }
    
    var header: HTTPHeaders {
        switch self {
        case .boxOffice:
            return [CCStrings.Network.apiHeader: APIConfig.kopisAPIKey]
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .boxOffice:
            return .get
        }
    }
    
    var params: Parameters {
        switch self {
        case .boxOffice(let startDate, let endDate, let genre, let area):
            var parameters: Parameters = [
                "stdate": startDate,
                "eddate": endDate
            ]
            
            if let genre = genre {
                parameters["catecode"] = genre.rawValue
            }
            
            if let area = area {
                parameters["area"] = area.rawValue
            }
            
            return parameters
        }
    }
}

//
//  APIRouter.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation
import Alamofire

enum APIRouter {
    case boxOffice(startDate: String, endDate: String, category: CategoryCode?, area: AreaCode?)
    case detailPerformance(performanceID: String)
}

extension APIRouter {
    var path: String {
        switch self {
        case .boxOffice:
            return "boxoffice"
        case .detailPerformance(let performanceID):
            return "pblprfr/\(performanceID)"
        }
    }
    
    var header: HTTPHeaders {
        switch self {
        case .boxOffice, .detailPerformance:
            return [CCStrings.Network.apiHeader: APIConfig.kopisAPIKey]
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .boxOffice, .detailPerformance:
            return .get
        }
    }
    
    var params: Parameters {
        switch self {
        case .boxOffice(let startDate, let endDate, let category, let area):
            var parameters: Parameters = [
                "stdate": startDate,
                "eddate": endDate
            ]
            
            if let category = category {
                parameters["catecode"] = category.rawValue
            }
            
            if let area = area {
                parameters["area"] = area.rawValue
            }
            
            return parameters
            
        case .detailPerformance:
            return [:]
        }
    }
}

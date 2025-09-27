//
//  NetworkManager.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation
import OSLog

import Alamofire
import Parsely

final class NetworkManager {
    
    // MARK: - Properties
    static let shared = NetworkManager()
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Network Request
    func request<T: ParselyType>(_ router: APIRouter, responseType: T.Type) async throws -> T {
        let url = APIConfig.baseURL + router.path
        
        #if DEBUG
        Logger.network.info("API 요청: \(url)")
        Logger.network.info("파라미터: \(router.params)")
        #endif
        
        let response = try await AF.request(url, method: router.method, parameters: router.params, headers: router.header)
            .validate(statusCode: 200..<300)
            .serializingString()
            .value
        
        #if DEBUG
        Logger.network.info("API 응답 성공")
        Logger.network.debug("응답 XML: \(response.prefix(200))...")
        #endif
        
        guard let parseData = T.parse(from: response) else {
            Logger.network.error("XML 파싱 에러")
            throw NetworkError.parsingFailed
        }
        
        return parseData
    }
}

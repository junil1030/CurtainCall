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
    
    // MARK: - Private Network Request
    func request<T: ParselyType>(_ router: APIRouter, responseType: T.Type) async throws -> T {
        let url = APIConfig.baseURL + router.path
        
        #if DEBUG
        Logger.network.info("API 요청: \(url)")
        Logger.network.info("파라미터: \(router.params)")
        #endif
        
        do {
            let response = try await AF.request(url, method: router.method, parameters: router.params, headers: router.header)
                .validate(statusCode: 200..<300)
                .serializingString()
                .value
            
            #if DEBUG
            Logger.network.info("API 응답 성공")
            Logger.network.debug("응답 XML: \(response.prefix(200))...")
            #endif
            
            try checkAPIError(response: response)
            
            guard let parseData = T.parse(from: response) else {
                Logger.network.error("XML 파싱 에러")
                throw NetworkError.parsingFailed
            }
            
            return parseData
            
        } catch let afError as AFError {
            Logger.network.error("Alamofire 에러: \(afError.localizedDescription)")
            throw handleAlamofireError(afError)
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            Logger.network.error("알 수 없는 에러: \(error.localizedDescription)")
            throw NetworkError.unknown(error)
        }
    }
    
    // MARK: - Private Method
    /// API 에러 응답 체크
    private func checkAPIError(response: String) throws {
        // 에러 응답인지 확인 (returncode 필드가 있는지)
        guard response.contains("<returncode>") else {
            return  // 에러 응답이 아님
        }
        
        guard let errorResponse = ErrorResponseDTO.parse(from: response) else {
            Logger.network.error("에러 응답 파싱 실패")
            throw NetworkError.parsingFailed
        }
        
        let errorDetail = errorResponse.dbs.db
        
        // returncode가 "00"이면 정상
        guard errorDetail.isError else {
            return
        }
        
        // 에러 코드가 정의된 코드인지 확인
        guard let errorCode = errorDetail.errorCode else {
            Logger.network.error("알 수 없는 에러 코드: \(errorDetail.returncode)")
            throw NetworkError.invalidResponse
        }
        
        Logger.network.error("API 에러: \(errorCode.rawValue) - \(errorDetail.errmsg)")
        
        // 특별한 처리가 필요한 에러들
        switch errorCode {
        case .noData:
            // 데이터 없음은 빈 배열로 처리할 수도 있지만, 일단 에러로 처리
            throw NetworkError.apiError(errorCode, errorDetail.errmsg)
        default:
            throw NetworkError.apiError(errorCode, errorDetail.errmsg)
        }
    }
    
    /// Alamofire 에러를 NetworkError로 변환
    private func handleAlamofireError(_ error: AFError) -> NetworkError {
        switch error {
        case .sessionTaskFailed(let sessionError):
            if let urlError = sessionError as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    return .noInternetConnection
                case .timedOut:
                    return .timeout
                default:
                    return .connectionFailed
                }
            }
            return .connectionFailed
            
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                return .serverError(code)
            }
            return .invalidResponse
            
        default:
            return .unknown(error)
        }
    }
}

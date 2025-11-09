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

// MARK: - Protocol 채택
final class NetworkManager: NetworkManagerProtocol {
    
    // MARK: - Init
    init() {}
    
    // MARK: - NetworkManagerProtocol
    func request<T: ParselyType>(_ router: APIRouter, responseType: T.Type) async throws -> T {
        let url = APIConfig.baseURL + router.path
        
        #if DEBUG
        Logger.network.info("API 요청: \(url)")
        Logger.network.info("파라미터: \(router.params)")
        #endif
        
        do {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 60
            
            let session = Session(configuration: configuration)
            
            let response = try await session.request(
                url,
                method: router.method,
                parameters: router.params,
                headers: router.header
            )
            .validate(statusCode: 200..<300)
            .serializingString(encoding: .utf8)
            .value
            
            #if DEBUG
            Logger.network.info("API 응답 성공")
            Logger.network.debug("응답 XML: \(response.prefix(200))...")
            #endif
            
            try checkAPIError(response: response)
            
            if isEmptyResponse(response) {
                #if DEBUG
                Logger.network.info("빈 응답 감지: <dbs/>")
                #endif
                // 빈 응답을 정상적으로 파싱할 수 있도록 빈 배열 구조로 변환
                return try createEmptyResponse(for: T.self)
            }
            
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
    
    // MARK: - Private Methods
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
    
    private func isEmptyResponse(_ response: String) -> Bool {
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
        // <dbs/> 또는 내용 없는 <dbs></dbs> 체크
        return trimmed.contains("<dbs/>") ||
               (trimmed.contains("<dbs>") && trimmed.contains("</dbs>") && !trimmed.contains("<db>"))
    }

    private func createEmptyResponse<T: ParselyType>(for type: T.Type) throws -> T {
        // SearchResponseDTO 타입인 경우에만 처리
        if type == SearchResponseDTO.self {
            let emptyResponse = SearchResponseDTO(
                dbs: SearchDatabaseDTO(db: [])
            )
            return emptyResponse as! T
        }
        
        // BoxOfficeResponseDTO 타입인 경우
        if type == BoxOfficeResponseDTO.self {
            let emptyResponse = BoxOfficeResponseDTO(
                boxofs: BoxOfficeListDTO(boxof: [])
            )
            return emptyResponse as! T
        }
        
        // 다른 타입은 파싱 에러 발생
        Logger.network.error("지원하지 않는 빈 응답 타입: \(type)")
        throw NetworkError.parsingFailed
    }
}

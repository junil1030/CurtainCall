//
//  NetworkManagerProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

import Foundation
import Parsely

// 네트워크 통신 프로토콜
protocol NetworkManagerProtocol {
    
    func request<T: ParselyType>(_ router: APIRouter, responseType: T.Type) async throws -> T
}

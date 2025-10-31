//
//  PerformanceRepositoryProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/28/25.
//

import Foundation

protocol PerformanceRepositoryProtocol {
    
    func fetchBoxOffice(genre: String, area: String) async throws -> [BoxOffice]
    func searchPerformances(keyword: String, area: String?)
}

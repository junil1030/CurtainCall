//
//  WidgetDeepLink.swift
//  CurtainCall
//
//  Created by 서준일 on 12/8/25.
//

import Foundation

/// Widget Deep Link 타입
enum WidgetDeepLink: Equatable {
    case home
    case favorites
    case records
    case performanceDetail(id: String)

    /// URL로 변환
    var url: URL? {
        let scheme = "curtaincall"

        switch self {
        case .home:
            return URL(string: "\(scheme)://home")
        case .favorites:
            return URL(string: "\(scheme)://favorites")
        case .records:
            return URL(string: "\(scheme)://records")
        case .performanceDetail(let id):
            return URL(string: "\(scheme)://performance/\(id)")
        }
    }

    /// URL에서 DeepLink 생성
    static func from(url: URL) -> WidgetDeepLink? {
        guard url.scheme == "curtaincall" else { return nil }

        let host = url.host
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "home":
            return .home
        case "favorites":
            return .favorites
        case "records":
            return .records
        case "performance":
            guard let id = pathComponents.first else { return nil }
            return .performanceDetail(id: id)
        default:
            return nil
        }
    }
}

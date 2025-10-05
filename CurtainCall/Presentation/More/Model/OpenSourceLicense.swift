//
//  OpenSourceLicense.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import Foundation

struct OpenSourceLicense {
    let name: String
    let url: String
    
    static let libraries: [OpenSourceLicense] = [
        OpenSourceLicense(
            name: "Alamofire",
            url: "https://github.com/Alamofire/Alamofire"
        ),
        OpenSourceLicense(
            name: "Kingfisher",
            url: "https://github.com/onevcat/Kingfisher"
        ),
        OpenSourceLicense(
            name: "Realm",
            url: "https://github.com/realm/realm-swift"
        ),
        OpenSourceLicense(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift"
        ),
        OpenSourceLicense(
            name: "SnapKit",
            url: "https://github.com/SnapKit/SnapKit"
        ),
        OpenSourceLicense(
            name: "Parsely",
            url: "https://github.com/ParselyKit/ParselyKit"
        )
    ]
}

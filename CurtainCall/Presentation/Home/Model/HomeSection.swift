//
//  HomeSection.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import Foundation

enum HomeSection: Int, CaseIterable {
    case category
    case filter
    case boxOffice
}

enum HomeItem: Hashable {
    case category
    case filter
    case boxOffice(CardItem)
}

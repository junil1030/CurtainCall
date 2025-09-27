//
//  CardItem.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation

protocol CardItemConvertible {
    func toCardItem() -> CardItem
}

struct CardItem: Hashable {
    let id: String
    let imageURL: String
    let title: String
    let subtitle: String
    let badge: String?
    let isFavorite: Bool
    
    // MARK: - Init
    init(
        id: String,
        imageURL: String,
        title: String,
        subtitle: String,
        badge: String? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.isFavorite = isFavorite
    }
}

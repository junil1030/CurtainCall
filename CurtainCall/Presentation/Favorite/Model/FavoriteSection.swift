//
//  FavoriteSection.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

enum FavoriteSection: Int, CaseIterable {
    case cards
}

enum FavoriteItem: Hashable {
    case favorite(CardItem)
}

//
//  BoxOffice.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation

struct BoxOffice {
    let rank: String
    let title: String
    let location: String
    let posterURL: String
    let perfomanceID: String
}

extension BoxOffice: CardItemConvertible {
    func toCardItem() -> CardItem {
        return CardItem(
            id: perfomanceID,
            imageURL: posterURL,
            title: title,
            subtitle: location,
            badge: rank,
            isFavorite: false  // 추후 찜하기 로직 연동
        )
    }
}

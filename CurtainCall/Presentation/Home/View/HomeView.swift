//
//  HomeView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit
import SnapKit
import RxSwift
import Kingfisher

final class HomeView: BaseView {
    
    private let genreCollectionView = GenreCollectionView()
    private let cardCollectionView = CardCollectionView()
    
    // MARK: - Observable
    var selectedCard: Observable<CardItem> {
        return cardCollectionView.selectedCard
    }
    
    var selectedGenre: Observable<CategoryCode?> {
        return genreCollectionView.selectedGenre
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        addSubview(genreCollectionView)
        addSubview(cardCollectionView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        genreCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        
        cardCollectionView.snp.makeConstraints { make in
            make.top.equalTo(genreCollectionView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Public Methods
    func updateBoxOfficeList(_ boxOffices: [BoxOffice]) {
        let cardItems = boxOffices.map { $0.toCardItem() }
        cardCollectionView.updateCards(with: cardItems)
    }
}

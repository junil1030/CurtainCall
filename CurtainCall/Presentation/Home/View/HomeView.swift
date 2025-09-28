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
    
    private let categoryCollectionView = CategoryCollectionView()
    private let filterButtonContainer = FilterButtonContainer()
    private let cardCollectionView = CardCollectionView()
    
    // MARK: - Observable
    var selectedCard: Observable<CardItem> {
        return cardCollectionView.selectedCard
    }
    
    var filterState: Observable<FilterButtonContainer.FilterState> {
        return filterButtonContainer.filterState
    }
    
    var selectedCategory: Observable<CategoryCode?> {
        return categoryCollectionView.selectedCategory
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        addSubview(categoryCollectionView)
        addSubview(filterButtonContainer)
        addSubview(cardCollectionView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        categoryCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        
        filterButtonContainer.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(8)
            make.height.equalTo(100)
        }
        
        cardCollectionView.snp.makeConstraints { make in
            make.top.equalTo(filterButtonContainer.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Public Methods
    func updateBoxOfficeList(_ boxOffices: [BoxOffice]) {
        let cardItems = boxOffices.map { $0.toCardItem() }
        cardCollectionView.updateCards(with: cardItems)
    }
    
    func scrollToFirstCard() {
        cardCollectionView.scrollToFirst()
    }

}

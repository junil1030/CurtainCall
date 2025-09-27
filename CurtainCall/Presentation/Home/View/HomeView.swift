//
//  HomeView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit
import SnapKit
import Kingfisher

final class HomeView: BaseView {
    
    private let categoryCollectionView = CategoryCollectionView()
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        addSubview(categoryCollectionView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        categoryCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
    }
}

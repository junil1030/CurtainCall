//
//  CategoryCollectionCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import RxSwift
import SnapKit

class CategoryCollectionCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let categoryView = CategoryCollectionView()
    
    // MARK: - Observables
    var selectedCategory: Observable<CategoryCode?> {
        return categoryView.selectedCategory
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(categoryView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        categoryView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

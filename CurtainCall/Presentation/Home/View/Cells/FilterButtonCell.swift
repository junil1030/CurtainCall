//
//  FilterButtonCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import RxSwift
import SnapKit

class FilterButtonCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let filterContainer = FilterButtonContainer()
    
    // MARK: - Observables
    var filterState: Observable<FilterButtonContainer.FilterState> {
        return filterContainer.filterState
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(filterContainer)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        filterContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

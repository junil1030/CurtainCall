//
//  GreetingBannerCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import RxSwift
import SnapKit

final class GreetingBannerCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let bannerView = GreetingBannerView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(bannerView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        bannerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

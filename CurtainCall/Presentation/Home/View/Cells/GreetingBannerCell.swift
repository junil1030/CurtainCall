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
    
    // MARK: - Observables
    var bannerTapped: Observable<Void> {
        return bannerView.didTapBanner
    }
    
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
    
    // MARK: - Public Methods
    func configure(nickname: String, profileImageURL: String) {
        bannerView.updateNickname(nickname)
        
        // 프로필 이미지 로드
        if !profileImageURL.isEmpty,
           let image = ProfileImageManager.shared.loadProfileImage(from: profileImageURL) {
            bannerView.updateProfileImage(image)
        } else {
            // 기본 이미지로 설정
            let defaultImage = UIImage(systemName: "person.fill")
            bannerView.updateProfileImage(defaultImage)
        }
    }
}

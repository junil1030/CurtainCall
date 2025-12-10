//
//  PosterCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import RxSwift
import SnapKit
import Kingfisher

final class PosterCell: BaseCollectionViewCell {
    
    // MARK: - UI Components
    // 배경 포스터 (흐림 효과)
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    // 밝은 블러 효과
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.alpha = 0.9
        return effectView
    }()
    
    // 하단 흰색 여백
    private let bottomWhiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // 작은 포스터 (3:4 비율)
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(blurEffectView)
        contentView.addSubview(bottomWhiteView)
        contentView.addSubview(posterImageView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        // 배경 이미지 - 전체 꽉 채움
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 블러 효과 - 배경 위에 겹침
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 하단 흰색 여백 - 아래쪽에만
        bottomWhiteView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        // 작은 포스터 - 3:4 비율, 높이 160pt
        posterImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(160)
            make.width.equalTo(posterImageView.snp.height).multipliedBy(3.0/4.0)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .white
    }
    
    func configure(with url: String) {
        if let imageURL = url.safeImageURL {
            posterImageView.setImage(with: imageURL,
                                     placeholder: UIImage(systemName: "photo"),
                                     cacheStrategy: .memoryOnly
            )
            
            posterImageView.setImage(with: imageURL,
                                     placeholder: UIImage(systemName: "photo"),
                                     cacheStrategy: .memoryOnly
            )
            // 킹피셔
            // 배경 이미지 로드
//            backgroundImageView.kf.setImage(
//                with: imageURL,
//                placeholder: UIImage(systemName: "photo.circle")?.withTintColor(.ccPrimary, renderingMode: .alwaysOriginal)
//            )
            
            // 작은 포스터 이미지 로드
//            posterImageView.kf.setImage(
//                with: imageURL,
//                placeholder: UIImage(systemName: "photo.circle")?.withTintColor(.ccPrimary, renderingMode: .alwaysOriginal),
//                options: [
//                    .transition(.fade(0.3)),
//                    .cacheOriginalImage
//                ]
//            )
        }
    }
}

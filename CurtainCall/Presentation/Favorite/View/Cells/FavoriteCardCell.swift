//
//  FavoriteCardCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import SnapKit
import Kingfisher

final class FavoriteCardCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccBodyBold
        label.textColor = .ccPrimaryText
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccSecondaryText
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private let textContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccBackground
        return view
    }()
    
    private let favoriteButton = FavoriteButton()
    
    // MARK: - Override Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        posterImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        favoriteButton.setFavorite(false)
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerView)
        containerView.addSubview(cardView)
        
        cardView.addSubview(posterImageView)
        cardView.addSubview(textContainerView)
        cardView.addSubview(favoriteButton)
        
        textContainerView.addSubview(titleLabel)
        textContainerView.addSubview(subtitleLabel)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        posterImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(textContainerView.snp.top)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(posterImageView).inset(8)
            make.width.height.equalTo(36)
        }
        
        textContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(22)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .clear
    }
    
    // MARK: - Configure
    func configure(with data: CardItem) {
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        favoriteButton.setFavorite(data.isFavorite)
        
        // 포스터 이미지 로드
        if let url = data.imageURL.safeImageURL {
            posterImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo.circle")?
                    .withTintColor(.ccPrimary, renderingMode: .alwaysOriginal),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        } else {
            posterImageView.image = UIImage(systemName: "photo.circle")?
                .withTintColor(.ccPrimary, renderingMode: .alwaysOriginal)
        }
        
        // 찜하기 버튼 이벤트
        favoriteButton.tapEvent
            .subscribe(with: self) { owner, _ in
                print("찜하기 버튼 클릭")
                // TODO: 찜하기 토글 로직
            }
            .disposed(by: disposeBag)
    }
}

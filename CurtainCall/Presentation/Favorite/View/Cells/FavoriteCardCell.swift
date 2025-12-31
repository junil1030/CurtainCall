//
//  FavoriteCardCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import SnapKit

protocol FavoriteCardCellDelegate: AnyObject {
    func favoriteCardCell(_ cell: FavoriteCardCell, didTapFavoriteButton performanceID: String)
}

final class FavoriteCardCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    weak var delegate: FavoriteCardCellDelegate?
    private var currentPerformanceID: String?
    
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
        currentPerformanceID = nil
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
    
    // MARK: - Binding
    private func bindFavoriteButton() {
        favoriteButton.tapEvent
            .subscribe(with: self) { owner, _ in
                guard let performanceID = owner.currentPerformanceID else { return }
                owner.delegate?.favoriteCardCell(owner, didTapFavoriteButton: performanceID)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    func configure(with data: CardItem) {
        currentPerformanceID = data.id
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        favoriteButton.setFavorite(data.isFavorite)
        bindFavoriteButton()
        
        // 포스터 이미지 로드
        if let url = data.imageURL.safeImageURL {
            posterImageView.setImage(with: url,
                                     placeholder: UIImage(systemName: "photo"),
                                     cacheStrategy: .both
            )
        } else {
            posterImageView.image = UIImage(systemName: "photo.circle")?
                .withTintColor(.ccPrimary, renderingMode: .alwaysOriginal)
        }
    }
    
    // MARK: - Public Methods
    func updateFavoriteStatus(_ isFavorite: Bool) {
        favoriteButton.setFavorite(isFavorite)
    }
}

//
//  CardCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import UIKit
import RxSwift
import SnapKit
import Kingfisher

final class CardCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "CardCell"
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .ccLargeTitleBold
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccHeadlineBold
        label.textColor = .ccPrimaryText
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccSecondaryText
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .ccPrimary
        button.backgroundColor = .white.withAlphaComponent(0.9)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        posterImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        rankLabel.text = nil
        favoriteButton.isSelected = false
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        contentView.addSubview(containerView)
        
        [posterImageView, rankLabel, titleLabel, subtitleLabel, favoriteButton].forEach {
            containerView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        posterImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(posterImageView.snp.width).multipliedBy(1.4) // 포스터 비율
        }
        
        rankLabel.snp.makeConstraints { make in
            make.bottom.leading.equalTo(posterImageView).inset(2)
            make.width.height.equalTo(50)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(posterImageView).inset(8)
            make.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }
    
    // MARK: - Configure
    func configure(with data: CardItem) {
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        rankLabel.text = data.badge
        
        // 포스터 이미지 로드
        if let url = data.imageURL.safeImageURL {
            posterImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        }
        
        // 찜하기 버튼 이벤트 (추후 구현)
        favoriteButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.favoriteButton.isSelected.toggle()
            }
            .disposed(by: disposeBag)
    }
}

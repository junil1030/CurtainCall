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
    
    // MARK: - Constants
    private let minimumTitleFontSize: CGFloat = 14
    private let maximumTitleFontSize: CGFloat = 20
    
    // MARK: - UI Components
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
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
        label.font = .ccTitle3Bold
        label.textColor = .ccPrimaryText
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
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
        [posterImageView, rankLabel, titleLabel, subtitleLabel, favoriteButton].forEach {
            contentView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        posterImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalTo(titleLabel.snp.top).offset(-8)
        }
        
        rankLabel.snp.makeConstraints { make in
            make.bottom.leading.equalTo(posterImageView).inset(8)
            make.width.height.lessThanOrEqualTo(50)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(posterImageView).inset(12)
            make.width.height.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(28) // 한 줄 고정 높이
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(20) // 부제목 고정 높이
            make.bottom.equalToSuperview().inset(8)
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
            ) { [weak self] result in
                switch result {
                case .success:
                    self?.posterImageView.addBottomGradient()
                case .failure:
                    break
                }
            }
        } else {
            posterImageView.addBottomGradient()
        }
        
        // 찜하기 버튼 이벤트 (추후 구현)
        favoriteButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.favoriteButton.isSelected.toggle()
            }
            .disposed(by: disposeBag)
    }
}

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

protocol CardCellDelegate: AnyObject {
    func cardCell(_ cell: CardCell, didTapFavoriteButton performanceID: String)
}

final class CardCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "CardCell"
    private var disposeBag = DisposeBag()
    weak var delegate: CardCellDelegate?
    private var currentPerformanceID: String?
    
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
    
    private let favoriteButton = FavoriteButton()
    
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
        favoriteButton.setFavorite(false)
        currentPerformanceID = nil
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
    
    private func bindFavoriteButton() {
        favoriteButton.tapEvent
            .subscribe(with: self) { owner, _ in
                guard let performanceID = owner.currentPerformanceID else { return }
                owner.delegate?.cardCell(owner, didTapFavoriteButton: performanceID)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    func configure(with data: CardItem) {
        currentPerformanceID = data.id
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        rankLabel.text = data.badge
        favoriteButton.setFavorite(data.isFavorite)
        bindFavoriteButton()
        
        // 포스터 이미지 로드
        if let url = data.imageURL.safeImageURL {
            posterImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo.circle")?.withTintColor(.ccPrimary, renderingMode: .alwaysOriginal),
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
    }
    
    // MARK: - Public Methods
    func updateFavoriteStatus(_ isFavorite: Bool) {
        favoriteButton.setFavorite(isFavorite)
    }
}

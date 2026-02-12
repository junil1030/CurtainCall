//
//  CardCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import UIKit
import RxSwift
import SnapKit
import CachingKit

final class CardCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    private var currentPerformanceID: String?
    private var isInitialLayoutCompleted = false
    private var imageLoadTask: Task<Void, Never>?
    
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
        label.font = .ccSubheadlineBold
        label.textColor = .ccPrimaryText
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccFootnote
        label.textColor = .ccSecondaryText
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = .ccFootnote
        label.textColor = .ccSecondaryText
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, periodLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        posterImageView.removeSkeletonShimmer()
        posterImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        periodLabel.text = nil
        rankLabel.text = nil
        currentPerformanceID = nil
        isInitialLayoutCompleted = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let cardHeight = bounds.height
        let fontSize = cardHeight / 6
        rankLabel.font = .nanumSquare(size: fontSize, isBold: true)

        posterImageView.updateSkeletonFrame()

        if !isInitialLayoutCompleted {
            isInitialLayoutCompleted = true

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.posterImageView.addBottomGradient()
            }
        }
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        [posterImageView, rankLabel, textStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        posterImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(posterImageView.snp.width).multipliedBy(4.0/3.0)
        }
        
        rankLabel.snp.makeConstraints { make in
            make.bottom.leading.equalTo(posterImageView).inset(12)
        }
        
        textStackView.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
    }
    
    // MARK: - Configure
    func configure(with data: CardItem) {
        currentPerformanceID = data.id
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        rankLabel.text = data.badge
        periodLabel.text = data.period

        // 이전 이미지 로드 취소
        imageLoadTask?.cancel()
        posterImageView.image = nil

        // 스켈레톤 시작
        posterImageView.showSkeletonShimmer()

        // 포스터 이미지 로드
        if let url = data.imageURL.safeImageURL {
            let performanceID = data.id
            let targetSize = posterImageView.bounds.size.width > 0
                ? posterImageView.bounds.size
                : CGSize(width: 300, height: 400)

            imageLoadTask = Task { @MainActor [weak self] in
                guard !Task.isCancelled else { return }

                let image = await CachingKit.shared.loadImage(
                    url: url,
                    targetSize: targetSize,
                    cacheStrategy: .both
                )

                guard !Task.isCancelled,
                      let self,
                      self.currentPerformanceID == performanceID else { return }

                self.posterImageView.removeSkeletonShimmer()
                self.posterImageView.image = image
            }
        }

        if !isInitialLayoutCompleted {
            layoutIfNeeded()
        }
    }
}

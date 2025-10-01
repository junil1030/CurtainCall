//
//  DetailPosterCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import SnapKit
import RxSwift

final class DetailPosterCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    private var isExpanded = false
    private var imageHeight: CGFloat = 0
    private let collapsedHeight: CGFloat = 300
    
    // MARK: - UI Components
    private let containerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "상세 정보"
        label.font = .ccHeadlineBold
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private lazy var toggleButton: UIButton = {
        let button = UIButton()
        button.setTitle("펼쳐보기", for: .normal)
        button.setTitleColor(.ccPrimary, for: .normal)
        button.titleLabel?.font = .ccCallout
        button.addTarget(self, action: #selector(toggleExpanded), for: .touchUpInside)
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        posterImageView.image = nil
        isExpanded = false
        posterImageView.snp.updateConstraints { make in
            make.height.equalTo(collapsedHeight)
        }
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerView)
        
        [titleLabel, posterImageView, toggleButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        posterImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(collapsedHeight)
        }
        
        toggleButton.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(with url: String) {
        if let imageURL = url.safeImageURL {
            posterImageView.kf.setImage(with: imageURL) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let value):
                    let screenWidth = UIScreen.main.bounds.width - 40
                    let calculatedHeight = value.image.size.height * screenWidth / value.image.size.width
                    self.imageHeight = calculatedHeight
                    
                    // expanded 상태라면 로드 직후 반영
                    if self.isExpanded {
                        self.posterImageView.snp.updateConstraints { make in
                            make.height.equalTo(self.imageHeight)
                        }
                        self.superview?.layoutIfNeeded()
                    }
                    
                case .failure:
                    break
                }
            }
        }
    }
    
    @objc private func toggleExpanded() {
        isExpanded.toggle()
        
        let newHeight = isExpanded ? imageHeight : collapsedHeight
        let buttonTitle = isExpanded ? "접기" : "펼쳐보기"
        
        posterImageView.snp.updateConstraints { make in
            make.height.equalTo(newHeight)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.toggleButton.setTitle(buttonTitle, for: .normal)
            self.contentView.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
        
        if let collectionView = self.superview as? UICollectionView {
            collectionView.performBatchUpdates(nil)
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}

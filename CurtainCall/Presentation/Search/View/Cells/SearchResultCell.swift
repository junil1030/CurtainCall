//
//  SearchResultCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit
import RxSwift
import SnapKit
import Kingfisher

final class SearchResultCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccBodyBold
        label.textColor = .ccPrimaryText
        label.numberOfLines = 1
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccPrimaryText
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccPrimaryText
        label.numberOfLines = 1
        return label
    }()
    
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.ccSeparator.cgColor
        return view
    }()
    
    // MARK: - Override Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        posterImageView.image = nil
        titleLabel.text = nil
        locationLabel.text = nil
        dateLabel.text = nil
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerView)
        containerView.addSubview(posterImageView)
        containerView.addSubview(textStackView)
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(locationLabel)
        textStackView.addArrangedSubview(dateLabel)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        posterImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(posterImageView.snp.height).multipliedBy(3.0/4.0)
        }
        
        textStackView.snp.makeConstraints { make in
            make.leading.equalTo(posterImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .clear
    }
    
    // MARK: - Configure
    func configure(with result: SearchResult) {
        titleLabel.text = result.title
        locationLabel.text = result.location
        dateLabel.text = "\(result.startDate) ~ \(result.endDate)"
        
        // 포스터 이미지 로드
        if let url = result.posterURL.safeImageURL {
            posterImageView.setImage(with: url,
                                     placeholder: UIImage(systemName: "photo"),
                                     cacheStrategy: .memoryOnly
            )
            // 킹피셔
//            posterImageView.kf.setImage(
//                with: url,
//                placeholder: UIImage(systemName: "photo")?
//                    .withTintColor(.ccSecondaryText, renderingMode: .alwaysOriginal)
//            )
        } else {
            posterImageView.image = UIImage(systemName: "photo")?
                .withTintColor(.ccSecondaryText, renderingMode: .alwaysOriginal)
        }
    }
}


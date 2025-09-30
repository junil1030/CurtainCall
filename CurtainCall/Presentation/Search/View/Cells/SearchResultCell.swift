//
//  SearchResultCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import UIKit
import SnapKit
import Kingfisher

final class SearchResultCell: BaseCollectionViewCell {
    
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
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccSecondaryText
        label.numberOfLines = 1
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccSecondaryText
        label.numberOfLines = 1
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        locationLabel.text = nil
    }
    
    // MARK: - Setup
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(infoStackView)
        
        [titleLabel, dateLabel, locationLabel].forEach {
            infoStackView.addArrangedSubview($0)
        }
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        posterImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(95)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.leading.equalTo(posterImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
    }
    
    // MARK: - Configure
    func configure(with result: SearchResult) {
        titleLabel.text = result.title
        dateLabel.text = "\(result.startDate) ~ \(result.endDate)"
        locationLabel.text = "\(result.area) > \(result.location)"
        
        if let url = result.posterURL.safeImageURL {
            posterImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo.circle")?.withTintColor(.ccPrimary, renderingMode: .alwaysOriginal),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        }
    }
}

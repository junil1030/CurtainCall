//
//  PerformanceInfoCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import SnapKit

final class PerformanceInfoCell: BaseCollectionViewCell {
    
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
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        posterImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(80)
        }
        
        textStackView.snp.makeConstraints { make in
            make.leading.equalTo(posterImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    func configure(with detail: PerformanceDetail) {
        let dateInfo: String
        let locationInfo: String
        
        if let startDate = detail.startDate, let endDate = detail.endDate {
            dateInfo = "\(startDate) ~ \(endDate)"
        } else {
            dateInfo = "공연 날짜에 대한 정보가 없어요"
        }
        
        if let area = detail.area, let location = detail.location {
            locationInfo = "\(area) > \(location)"
        } else {
            locationInfo = "장소에 대한 정보가 없어요"
        }
        
        titleLabel.text = detail.title
        locationLabel.text = locationInfo
        dateLabel.text = dateInfo
        
        if let url = detail.posterURL.safeImageURL {
            posterImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo.circle")?.withTintColor(.ccPrimary, renderingMode: .alwaysOriginal),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        }
    }
}

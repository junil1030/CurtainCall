//
//  SectionTitleView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import UIKit
import SnapKit

final class SectionTitleView: UICollectionReusableView {
    
    static let identifier = "SectionTitleView"
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ccPrimary
        return imageView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .ccBackground
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    func configure(title: String, icon: UIImage?) {
        titleLabel.text = title
        iconImageView.image = icon
        iconImageView.isHidden = (icon == nil)
        
        // 아이콘이 없으면 타이틀을 왼쪽으로
        if icon == nil {
            titleLabel.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(4)
                make.centerY.equalToSuperview()
            }
        }
    }
}

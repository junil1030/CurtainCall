//
//  CompanionCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import UIKit
import SnapKit

final class CompanionCell: BaseCollectionViewCell {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36)
        label.textAlignment = .center
        return label
    }()
    
    private let companionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .ccPrimaryText
        label.textAlignment = .center
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .ccPrimary
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Override Methods
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(emojiLabel)
        containerView.addSubview(companionLabel)
        containerView.addSubview(countLabel)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        emojiLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        companionLabel.snp.makeConstraints { make in
            make.top.equalTo(emojiLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(companionLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .clear
    }
    
    // MARK: - Configure
    
    func configure(with item: CompanionItem) {
        emojiLabel.text = item.emoji
        companionLabel.text = item.companion
        countLabel.text = "\(item.count)편"
    }
}

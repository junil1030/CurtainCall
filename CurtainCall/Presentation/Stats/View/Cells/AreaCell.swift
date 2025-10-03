//
//  AreaCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import UIKit
import SnapKit

final class AreaCell: BaseCollectionViewCell {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let rankBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let areaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .ccPrimary
        return label
    }()
    
    // MARK: - Override Methods
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(rankBadge)
        rankBadge.addSubview(rankLabel)
        
        containerView.addSubview(areaLabel)
        containerView.addSubview(countLabel)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rankBadge.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        rankLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        areaLabel.snp.makeConstraints { make in
            make.leading.equalTo(rankBadge.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .clear
    }
    
    // MARK: - Configure
    
    func configure(with item: AreaItem) {
        rankLabel.text = "\(item.rank)"
        areaLabel.text = item.area
        countLabel.text = "\(item.count)편"
        
        // 순위별 배지 색상
        rankBadge.backgroundColor = getRankColor(for: item.rank)
    }
    
    // MARK: - Helper
    
    private func getRankColor(for rank: Int) -> UIColor {
        switch rank {
        case 1:
            return UIColor(red: 255/255, green: 179/255, blue: 128/255, alpha: 1.0) // 금색 느낌
        case 2:
            return UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 1.0) // 은색 느낌
        case 3:
            return UIColor(red: 92/255, green: 138/255, blue: 138/255, alpha: 1.0)  // 동색 느낌
        default:
            return UIColor.systemGray
        }
    }
}

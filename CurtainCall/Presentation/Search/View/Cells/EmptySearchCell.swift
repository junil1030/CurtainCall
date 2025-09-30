//
//  EmptySearchCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit
import SnapKit

final class EmptySearchCell: BaseCollectionViewCell {
    
    // MARK: - UI Components
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "원하는 공연을 입력해보세요!"
        label.font = .ccBody
        label.textColor = .ccSecondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Override Methods
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(messageLabel)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .ccBackground
    }
}

//
//  EmptyStateView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import UIKit
import SnapKit

final class EmptyStateView: BaseView {
    
    // MARK: - UI Components
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ccSecondaryText
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .ccBody
        label.textColor = .ccSecondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(messageLabel)
    }
    
    override func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .clear
    }
    
    // MARK: - Configure
    func configure(icon: UIImage?, message: String) {
        iconImageView.image = icon
        messageLabel.text = message
    }
}

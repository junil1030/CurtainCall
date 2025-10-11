//
//  InfoItemView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import UIKit
import SnapKit

final class InfoItemView: BaseView {
    
    // MARK: - UI Components
    private let symbolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ccPrimary
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .ccBody
        label.textColor = .ccPrimaryText
        label.numberOfLines = 0
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(symbolImageView)
        stackView.addArrangedSubview(textLabel)
    }
    
    override func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        symbolImageView.snp.makeConstraints { make in
            make.width.height.lessThanOrEqualTo(24)
            make.width.equalTo(symbolImageView.snp.height)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .clear
    }
    
    // MARK: - Public Methods
    func configure(symbol: String, text: String, symbolColor: UIColor = .ccPrimary) {
        symbolImageView.image = UIImage(systemName: symbol)
        symbolImageView.tintColor = symbolColor
        textLabel.text = text
    }
}

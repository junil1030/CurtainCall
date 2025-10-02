//
//  FavoriteHeaderView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//


import UIKit
import SnapKit

final class FavoriteHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    static let identifier = "FavoireheaderView"
    
    // MARK: - UI Componenets
    private let totalCountLabel: UILabel = {
        let label = UILabel()
        label.font = .ccTitle3Bold
        label.textColor = .ccPrimaryText
        label.numberOfLines = 1
        return label
    }()
    
    private let monthlyCountLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccSecondaryText
        label.numberOfLines = 1
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .ccBackground
        
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.ccPrimary.cgColor
        
        addSubview(stackView)
        
        stackView.addArrangedSubview(totalCountLabel)
        stackView.addArrangedSubview(monthlyCountLabel)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(25)
        }
    }
    
    // MARK: - Configure
    func configure(totalCount: Int, monthlyCount: Int) {
        totalCountLabel.text = "총 \(totalCount)개의 찜한 공연이 있어요"
        monthlyCountLabel.text = "이번 달 새로 추가된 공연 \(monthlyCount)개"
    }
}

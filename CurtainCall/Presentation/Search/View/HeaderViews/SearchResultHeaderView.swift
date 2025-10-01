//
//  SearchResultHeaderView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit
import RxSwift
import SnapKit

final class SearchResultHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    static let identifier = "SearchResultHeaderView"
    
    // MARK: - UI Components
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .ccBody
        label.textColor = .ccPrimaryText
        return label
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
        backgroundColor = .clear
        addSubview(resultLabel)
        
        resultLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    func configure(keyword: String, count: Int) {
        let attributedString = NSMutableAttributedString()
        
        // keyword만 볼드처리 함
        let keywordAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ccBodyBold,
            .foregroundColor: UIColor.ccPrimaryText
        ]
        attributedString.append(NSAttributedString(string: "\"\(keyword)\"", attributes: keywordAttributes))
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ccBody,
            .foregroundColor: UIColor.ccPrimaryText
        ]
        attributedString.append(NSAttributedString(string: " 검색 결과 \(count)건", attributes: normalAttributes))
        
        resultLabel.attributedText = attributedString
    }
}

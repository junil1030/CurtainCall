//
//  CastInfoView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/21/25.
//

import UIKit
import SnapKit

final class CastInfoView: BaseView {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "출연진 정보가 없어요"
        label.font = .ccBody
        label.textColor = .ccSecondaryText
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(scrollView)
        addSubview(emptyLabel)
        scrollView.addSubview(stackView)
    }
    
    override func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalToSuperview().offset(-40)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
    }
    
    // MARK: - Public Methods
    func configure(with cast: [String]?) {
        // 기존 뷰 제거
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        guard let castList = cast, !castList.isEmpty else {
            emptyLabel.isHidden = false
            scrollView.isHidden = true
            return
        }
        
        emptyLabel.isHidden = true
        scrollView.isHidden = false
        
        // 각 출연진 정보 생성
        castList.enumerated().forEach { index, name in
            let castRow = createCastRow(name: name, index: index + 1)
            stackView.addArrangedSubview(castRow)
        }
    }
    
    // MARK: - Private Methods
    private func createCastRow(name: String, index: Int) -> UIView {
        let containerView = UIView()
        
        let numberLabel = UILabel()
        numberLabel.text = "\(index)"
        numberLabel.font = .ccBodyBold
        numberLabel.textColor = .ccPrimary
        numberLabel.textAlignment = .center
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .ccSubheadline
        nameLabel.textColor = .ccPrimaryText
        nameLabel.numberOfLines = 0
        
        containerView.addSubview(numberLabel)
        containerView.addSubview(nameLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(numberLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        return containerView
    }
}

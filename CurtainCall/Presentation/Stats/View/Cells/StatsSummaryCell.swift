//
//  StatsSummaryCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import UIKit
import SnapKit

final class StatsSummaryCell: BaseCollectionViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    // 메인 카운트
    private let mainCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .ccPrimaryText
        label.textAlignment = .center
        return label
    }()
    
    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ccSecondaryText
        label.textAlignment = .center
        return label
    }()
    
    // 3개 정보 스택
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    // 구분선
    private let divider1 = createDivider()
    private let divider2 = createDivider()
    
    // 정보 컨테이너들
    private let changeInfoView = InfoContainerView()
    private let ratingInfoView = InfoContainerView()
    private let specialInfoView = InfoContainerView()
    
    // MARK: - Override Methods
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(mainCountLabel)
        containerView.addSubview(periodLabel)
        containerView.addSubview(infoStackView)
        
        infoStackView.addArrangedSubview(changeInfoView)
        infoStackView.addArrangedSubview(ratingInfoView)
        infoStackView.addArrangedSubview(specialInfoView)
        
        containerView.addSubview(divider1)
        containerView.addSubview(divider2)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        mainCountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        periodLabel.snp.makeConstraints { make in
            make.top.equalTo(mainCountLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(periodLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(80)
        }
        
        divider1.snp.makeConstraints { make in
            make.centerY.equalTo(infoStackView)
            make.centerX.equalTo(infoStackView).multipliedBy(0.666)
            make.height.equalTo(50)
            make.width.equalTo(1)
        }
        
        divider2.snp.makeConstraints { make in
            make.centerY.equalTo(infoStackView)
            make.centerX.equalTo(infoStackView).multipliedBy(1.334)
            make.height.equalTo(50)
            make.width.equalTo(1)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .clear
    }
    
    // MARK: - Configure
    func configure(with item: StatsSummaryItem) {
        // 메인 카운트
        mainCountLabel.text = "\(item.currentCount)"
        
        // 기간 라벨
        switch item.period {
        case .weekly:
            periodLabel.text = "이번 주 관람"
        case .monthly:
            periodLabel.text = "이번 달 관람"
        case .yearly:
            periodLabel.text = "올해 총 관람"
        }
        
        // 변화량
        let changeText = item.changeText
        let changeColor: UIColor = item.changeCount > 0 ? .systemRed :
                                   item.changeCount < 0 ? .systemBlue : .ccPrimaryText
        
        changeInfoView.configure(
            title: "지난 기간 대비",
            value: changeText,
            valueColor: changeColor
        )
        
        // 평균 평점
        let ratingText = String(format: "%.1f", item.averageRating)
        ratingInfoView.configure(
            title: "평균 평점",
            value: ratingText,
            valueColor: .ccPrimaryText
        )
        
        // 특별 정보 (최다 요일/장르/달)
        specialInfoView.configure(
            title: item.specialInfoTitle,
            value: item.specialInfoValue,
            valueColor: .ccPrimaryText
        )
    }
    
    // MARK: - Helper
    private static func createDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }
}

// MARK: - InfoContainerView
private final class InfoContainerView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ccSecondaryText
        label.textAlignment = .center
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        valueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }
    
    func configure(title: String, value: String, valueColor: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = valueColor
    }
}

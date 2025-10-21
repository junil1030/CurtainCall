//
//  ProductionInfoView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/21/25.
//

import UIKit
import SnapKit

final class ProductionInfoView: BaseView {
    
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()
    
    // MARK: - Info Rows
    private lazy var producerRow = createInfoRow()
    private lazy var planningRow = createInfoRow()
    private lazy var hostRow = createInfoRow()
    private lazy var managementRow = createInfoRow()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "제작 정보가 없어요"
        label.font = .ccBody
        label.textColor = .ccSecondaryText
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(stackView)
        addSubview(emptyLabel)
        
        [producerRow, planningRow, hostRow, managementRow].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    override func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
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
    func configure(with detail: PerformanceDetail) {
        var hasData = false
        
        // 제작사
        if let producer = detail.producer, !producer.isEmpty {
            configureRow(producerRow, title: "제작사", value: producer)
            producerRow.isHidden = false
            hasData = true
        } else {
            producerRow.isHidden = true
        }
        
        // 기획사
        if let planning = detail.planning, !planning.isEmpty {
            configureRow(planningRow, title: "기획사", value: planning)
            planningRow.isHidden = false
            hasData = true
        } else {
            planningRow.isHidden = true
        }
        
        // 주최
        if let host = detail.host, !host.isEmpty {
            configureRow(hostRow, title: "주최", value: host)
            hostRow.isHidden = false
            hasData = true
        } else {
            hostRow.isHidden = true
        }
        
        // 주관
        if let management = detail.management, !management.isEmpty {
            configureRow(managementRow, title: "주관", value: management)
            managementRow.isHidden = false
            hasData = true
        } else {
            managementRow.isHidden = true
        }
        
        // 데이터 유무에 따른 표시
        stackView.isHidden = !hasData
        emptyLabel.isHidden = hasData
    }
    
    // MARK: - Private Methods
    private func createInfoRow() -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.font = .ccBody
        titleLabel.textColor = .ccSecondaryText
        titleLabel.tag = 100 // title label tag
        
        let valueLabel = UILabel()
        valueLabel.font = .ccBody
        valueLabel.textColor = .ccPrimaryText
        valueLabel.numberOfLines = 0
        valueLabel.tag = 200 // value label tag
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(20)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        return containerView
    }
    
    private func configureRow(_ row: UIView, title: String, value: String) {
        if let titleLabel = row.viewWithTag(100) as? UILabel {
            titleLabel.text = title
        }
        
        if let valueLabel = row.viewWithTag(200) as? UILabel {
            valueLabel.text = value
        }
    }
}

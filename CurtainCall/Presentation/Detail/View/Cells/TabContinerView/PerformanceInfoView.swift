//
//  PerformanceInfoView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/21/25.
//

import UIKit
import SnapKit

final class PerformanceInfoView: BaseView {
    
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
    private lazy var runtimeRow = createInfoRow()
    private lazy var ageRatingRow = createInfoRow()
    private lazy var ticketPriceRow = createInfoRow()
    private lazy var locationRow = createInfoRow()
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(stackView)
        
        [runtimeRow, ageRatingRow, ticketPriceRow, locationRow].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    override func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
    }
    
    // MARK: - Public Methods
    func configure(with detail: PerformanceDetail) {
        // 공연시간
        let runtimeText = detail.runtime ?? "정보 없음"
        configureRow(runtimeRow, title: "공연시간", value: runtimeText)
        
        // 관람연령
        let ageRatingText = detail.ageRating ?? "정보 없음"
        configureRow(ageRatingRow, title: "관람연령", value: ageRatingText)
        
        // 티켓가격
        let ticketPriceText = detail.ticketPrice ?? "정보 없음"
        configureRow(ticketPriceRow, title: "티켓가격", value: ticketPriceText)
        
        // 장소
        let locationText: String
        if let area = detail.area, let location = detail.location {
            locationText = "\(area) > \(location)"
        } else {
            locationText = "정보 없음"
        }
        configureRow(locationRow, title: "장소", value: locationText)
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

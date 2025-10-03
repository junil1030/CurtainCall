//
//  TrendChartCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import UIKit
import SwiftUI
import SnapKit

final class TrendChartCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    private var hostingController: UIHostingController<TrendChartView>?
    
    // MARK: - UIComponents
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Override Methods
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        hostingController?.view.removeFromSuperview()
        hostingController = nil
    }
    
    // MARK: - Configure
    func configure(with item: TrendChartItem) {
        // 기존 HostingController 제거
        hostingController?.view.removeFromSuperview()
        hostingController = nil
        
        // SwiftUI View 생성
        let chartView = TrendChartView(
            dataPoints: item.dataPoints,
            period: item.period
        )
        
        // HostingController로 래핑
        let hosting = UIHostingController(rootView: chartView)
        hosting.view.backgroundColor = .clear
        hostingController = hosting
        
        // ContainerView에 추가
        containerView.addSubview(hosting.view)
        hosting.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

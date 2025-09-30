//
//  InfoCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import SnapKit

final class InfoCell: BaseCollectionViewCell {
    
    // MARK: - UI Components
    private let infoItemView = InfoItemView()
    
    override func setupHierarchy() {
        super.setupHierarchy()
        contentView.addSubview(infoItemView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        infoItemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with data: DetailView.InfoData) {
        infoItemView.configure(symbol: data.symbol, text: data.text)
    }
}

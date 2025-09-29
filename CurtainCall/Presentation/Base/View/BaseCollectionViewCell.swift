//
//  BaseCollectionViewCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupHierarchy()
        setupLayout()
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHierarchy() {}
    
    func setupLayout() {}
    
    func setupStyle() {}
}

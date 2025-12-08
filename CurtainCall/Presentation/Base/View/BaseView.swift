//
//  BaseView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit

class BaseView: UIView {
    
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
    func setupStyle() {
        self.backgroundColor = UIColor.ccBackground
    }
}

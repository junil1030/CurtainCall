//
//  UIView+Extension.swift
//  CurtainCall
//
//  Created by 서준일 on 10/17/25.
//

import UIKit

extension UIView {
    func addBottomGradient() {
        layer.sublayers?.forEach { sublayer in
            if sublayer is CAGradientLayer {
                sublayer.removeFromSuperlayer()
            }
        }
        
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradient.locations = [0.5, 1.0]
        layer.addSublayer(gradient)
    }
}

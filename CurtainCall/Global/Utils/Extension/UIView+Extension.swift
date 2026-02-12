//
//  UIView+Extension.swift
//  CurtainCall
//
//  Created by 서준일 on 10/17/25.
//

import UIKit

// MARK: - Skeleton Animation
extension UIView {
    fileprivate static let skeletonLayerName = "skeletonShimmerLayer"

    func showSkeletonShimmer() {
        // 이미 스켈레톤이 있으면 제거 후 다시 추가
        removeSkeletonShimmer()

        let shimmerLayer = CAGradientLayer()
        shimmerLayer.name = UIView.skeletonLayerName
        shimmerLayer.frame = bounds
        shimmerLayer.cornerRadius = layer.cornerRadius
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)

        let baseColor = UIColor.systemGray5.cgColor
        let highlightColor = UIColor.systemGray3.cgColor

        shimmerLayer.colors = [baseColor, highlightColor, baseColor]
        shimmerLayer.locations = [-0.5, -0.25, 0]

        layer.addSublayer(shimmerLayer)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-0.5, -0.25, 0]
        animation.toValue = [1, 1.25, 1.5]
        animation.duration = 1.2
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false

        shimmerLayer.add(animation, forKey: "shimmerAnimation")
    }

    func removeSkeletonShimmer() {
        layer.sublayers?.removeAll { $0.name == UIView.skeletonLayerName }
    }

    func updateSkeletonFrame() {
        layer.sublayers?
            .filter { $0.name == UIView.skeletonLayerName }
            .forEach { $0.frame = bounds }
    }
}

// MARK: - Gradient
extension UIView {
    func addBottomGradient() {
        layer.sublayers?.forEach { sublayer in
            if sublayer is CAGradientLayer,
               sublayer.name != UIView.skeletonLayerName {
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
    
    func findFirstResponderInSubviews() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        
        for subview in subviews {
            if let firstResponder = subview.findFirstResponderInSubviews() {
                return firstResponder
            }
        }
        
        return nil
    }
}

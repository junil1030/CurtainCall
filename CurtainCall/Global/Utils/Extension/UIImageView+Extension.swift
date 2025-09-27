//
//  UIImageView+Extension.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import UIKit

extension UIImageView {
    
    /// 이미지뷰 하단에 그라데이션 오버레이를 추가합니다
    /// - Parameters:
    ///   - colors: 그라데이션 색상 배열 (기본값: 투명 -> 검정)
    ///   - height: 그라데이션 높이 비율 (0.0 ~ 1.0, 기본값: 0.3)
    func addBottomGradient(colors: [UIColor] = [.clear, .black.withAlphaComponent(0.7)], height: CGFloat = 0.3) {
        // 기존 그라데이션 레이어 제거
        removeBottomGradient()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.name = "bottomGradient"
        
        // 레이어 추가
        layer.addSublayer(gradientLayer)
        
        // 레이아웃 업데이트를 위한 콜백 설정
        Task { @MainActor in
            self.updateGradientFrame(height: height)
        }
    }
    
    /// 그라데이션 레이어의 프레임을 업데이트합니다
    /// - Parameter height: 그라데이션 높이 비율
    private func updateGradientFrame(height: CGFloat) {
        guard let gradientLayer = layer.sublayers?.first(where: { $0.name == "bottomGradient" }) as? CAGradientLayer else {
            return
        }
        
        let gradientHeight = bounds.height * height
        gradientLayer.frame = CGRect(
            x: 0,
            y: bounds.height - gradientHeight,
            width: bounds.width,
            height: gradientHeight
        )
    }
    
    /// 하단 그라데이션을 제거합니다
    func removeBottomGradient() {
        layer.sublayers?.removeAll { $0.name == "bottomGradient" }
    }
    
    /// 뷰의 레이아웃이 변경될 때 그라데이션 프레임을 업데이트합니다
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        // 그라데이션 레이어가 있다면 프레임 업데이트
        if layer.sublayers?.contains(where: { $0.name == "bottomGradient" }) == true {
            updateGradientFrame(height: 0.3)
        }
    }
}

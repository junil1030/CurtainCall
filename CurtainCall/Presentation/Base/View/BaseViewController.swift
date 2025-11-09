//
//  BaseViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupStyle()
        setupBind()
    }

    func setupLayout() {
        navigationItem.backButtonTitle = ""
    }
    
    func setupStyle() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ccBackground
        appearance.shadowColor = .clear
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        
        navigationBar.backgroundColor = .clear
        navigationBar.tintColor = .ccPrimary
    }
    
    func setupBind() {}
    
    func changeRootViewController(to vc: UIViewController) {
        guard let window = view.window else { return }
        window.rootViewController = vc
    }
    
    func setNavigationbarHidden(_ hidden: Bool) {
        navigationController?.navigationBar.isHidden = hidden
    }
    
    // MARK: - Toast
    func showToast(message: String, type: ToastType, duration: TimeInterval = 2.5) {
        // 토스트 컨테이너 뷰
        let toastContainer = UIView()
        toastContainer.backgroundColor = type.backgroundColor
        toastContainer.layer.cornerRadius = 12
        toastContainer.clipsToBounds = true
        toastContainer.alpha = 0
        
        // 아이콘 이미지뷰
        let iconImageView = UIImageView()
        if let iconName = type.icon {
            iconImageView.image = UIImage(systemName: iconName)
            iconImageView.tintColor = type.textColor
            iconImageView.contentMode = .scaleAspectFit
        }
        
        // 메시지 레이블
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = type.textColor
        messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        messageLabel.textAlignment = .left
        messageLabel.numberOfLines = 0
        
        // 스택뷰 구성
        let stackView = UIStackView(arrangedSubviews: [iconImageView, messageLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        
        toastContainer.addSubview(stackView)
        view.addSubview(toastContainer)

        // 레이아웃 설정
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        toastContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        // 애니메이션
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            toastContainer.alpha = 1.0
        } completion: { _ in
            // 자동 dismiss
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseIn) {
                toastContainer.alpha = 0
            } completion: { _ in
                toastContainer.removeFromSuperview()
            }
        }

    }
}

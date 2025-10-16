//
//  BaseViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit

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
        navigationController?.navigationBar.tintColor = .ccNavigationTint
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    func setupBind() {}
    
    func changeRootViewController(to vc: UIViewController) {
        guard let window = view.window else { return }
        window.rootViewController = vc
    }
    
    func setNavigationbarHidden(_ hidden: Bool) {
        navigationController?.navigationBar.isHidden = hidden
    }
}

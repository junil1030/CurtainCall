//
//  FavoriteButton.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class FavoriteButton: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .systemRed
        button.backgroundColor = .clear
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Observables
    private let isFavoriteRelay = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Public Observables
    var isFavorite: Observable<Bool> {
        return isFavoriteRelay.asObservable()
    }
    
    var tapEvent: Observable<Void> {
        return button.rx.tap.asObservable()
    }
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(button)
    }
    
    override func setupLayout() {
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(36)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .clear
        bindActions()
    }
    
    // MARK: - Setup Methods
    private func bindActions() {
        button.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.toggleFavorite()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func toggleFavorite() {
        let newState = !isFavoriteRelay.value
        isFavoriteRelay.accept(newState)
        button.isSelected = newState
    }
    
    // MARK: - Public Methods
    func setFavorite(_ isFavorite: Bool) {
        isFavoriteRelay.accept(isFavorite)
        button.isSelected = isFavorite
    }
}

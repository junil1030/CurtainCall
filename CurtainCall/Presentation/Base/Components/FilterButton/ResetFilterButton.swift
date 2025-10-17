//
//  ResetFilterButton.swift
//  CurtainCall
//
//  Created by 서준일 on 10/17/25.
//

import UIKit
import RxSwift
import RxCocoa

/// 초기화 필터 버튼
/// - 버튼 탭 시 "reset" 값을 방출하여 필터 초기화
final class ResetFilterButton: BaseFilterButton {
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateTitle("초기화")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    override func getDefaultIcon() -> UIImage? {
        return UIImage(systemName: "arrow.trianglehead.clockwise.rotate.90")
    }
    
    override func setupButtonAction() {
        rx.tap
            .subscribe(with: self) { owner, _ in
                owner.handleReset()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func handleReset() {
        updateSelectedValue("reset")
    }
}

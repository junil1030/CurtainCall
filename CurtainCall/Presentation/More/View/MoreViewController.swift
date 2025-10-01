//
//  MoreViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MoreViewController: BaseViewController {
    
    // MARK: - Properties
    private let moreView = MoreView()
    private let viewModel = MoreViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func loadView() {
        view = moreView
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.title = CCStrings.Title.moreName
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = MoreViewModel.Input(
            menuItemSelected: moreView.menuItemSelected
        )
        
        let output = viewModel.transform(input: input)
        
        // 프로필 데이터 바인딩
        output.profileData
            .drive(with: self) { owner, data in
                owner.moreView.configure(with: data)
            }
            .disposed(by: disposeBag)
        
        // 메뉴 액션 처리
        output.handleMenuAction
            .emit(with: self) { owner, action in
                owner.handleMenuAction(action)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func handleMenuAction(_ action: MoreViewModel.MenuAction) {
        switch action {
        case .showPrivacyPolicy:
            print("개인정보 처리방침 표시")
            // TODO: 개인정보 처리방침 화면으로 이동
            
        case .showOpenSourceLicense:
            print("오픈소스 라이선스 표시")
            // TODO: 오픈소스 라이선스 화면으로 이동
            
        case .openContact:
            print("문의하기 열기")
            // TODO: 이메일 앱 열기
            
        case .openAppStoreReview:
            print("앱스토어 리뷰 열기")
            // TODO: 앱스토어 리뷰 페이지 열기
        }
    }
}

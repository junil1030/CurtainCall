//
//  MoreViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MoreViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UseCases
    private let getUserProfileUseCase: GetUserProfileUseCase
    
    // MARK: - Streams
    private let userProfileRelay = BehaviorRelay<UserProfile?>(value: nil)
    
    // MARK: - Input / Output
    struct Input {
        let viewWillAppear: Observable<Void>
        let profileViewTapped: Observable<Void>
        let menuItemSelected: Observable<MoreMenuItem>
    }
    
    struct Output {
        let userProfile: Driver<UserProfile?>
        let navigateToProfileEdit: Signal<Void>
        let handleMenuAction: Signal<MenuAction>
    }
    
    enum MenuAction {
        case showPrivacyPolicy
        case showOpenSourceLicense
        case openContact
        case openAppStoreReview
    }
    
    // MARK: - Init
    init(getUserProfileUseCase: GetUserProfileUseCase) {
        self.getUserProfileUseCase = getUserProfileUseCase
        super.init()
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        
        // viewWillAppear 시 프로필 다시 로드
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                owner.loadUserProfile()
            }
            .disposed(by: disposeBag)
        
        // 프로필 뷰 탭 -> 프로필 편집 화면으로 이동
        let navigateToProfileEdit = input.profileViewTapped
            .asSignal(onErrorSignalWith: .empty())
        
        // 메뉴 아이템 선택 -> 액션 처리
        let menuAction = input.menuItemSelected
            .map { item -> MenuAction in
                switch item {
                case .privacyPolicy:
                    return .showPrivacyPolicy
                case .openSourceLicense:
                    return .showOpenSourceLicense
                case .contact:
                    return .openContact
                case .appStoreReview:
                    return .openAppStoreReview
                }
            }
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            userProfile: userProfileRelay.asDriver(),
            navigateToProfileEdit: navigateToProfileEdit,
            handleMenuAction: menuAction
        )
    }
    
    // MARK: - Private Methods
    private func loadUserProfile() {
        let profile = getUserProfileUseCase.execute(())
        userProfileRelay.accept(profile)
    }
}

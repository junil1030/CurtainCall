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
    
    // MARK: - Streams
    private let profileDataRelay = BehaviorRelay<ProfileExperienceData>(value: MoreViewModel.createDummyData())
    
    // MARK: - Input / Output
    struct Input {
        let menuItemSelected: Observable<MoreMenuItem>
    }
    
    struct Output {
        let profileData: Driver<ProfileExperienceData>
        let handleMenuAction: Signal<MenuAction>
    }
    
    enum MenuAction {
        case showPrivacyPolicy
        case showOpenSourceLicense
        case openContact
        case openAppStoreReview
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        
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
            profileData: profileDataRelay.asDriver(),
            handleMenuAction: menuAction
        )
    }
    
    // MARK: - Private Methods
    private static func createDummyData() -> ProfileExperienceData {
        return ProfileExperienceData(
            nickname: "닉네임",
            subtitle: "안녕하세요!",
            level: 5,
            currentExp: 24,
            maxExp: 30
        )
    }
}

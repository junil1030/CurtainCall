//
//  ProfileEditViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileEditViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UseCase
    private let getUserProfileUseCase: GetUserProfileUseCase
    private let updateProfileImageUseCase: UpdateProfileImageUseCase
    private let updateNicknameUseCase: UpdateNicknameUseCase
    
    // MARK: - Streams
    private let currentProfileRelay = BehaviorRelay<UserProfile?>(value: nil)
    private let saveSuccessRelay = PublishRelay<Void>()
    private let saveErrorRelay = PublishRelay<Error>()
    private let nicknameValidationRelay = BehaviorRelay<NicknameValidation>(value: .idle)
    
    // MARK: - Validation State
    enum NicknameValidation {
        case idle
        case valid
        case empty
        case tooLong
        
        var message: String? {
            switch self {
            case .idle, .valid:
                return nil
            case .empty:
                return "닉네임을 입력해주세요."
            case .tooLong:
                return "닉네임은 10자 이하로 입력해주세요."
            }
        }
        
        var isValid: Bool {
            return self == .valid
        }
    }
    
    // MARK: - Input / Output
    struct Input {
        let imageSelected: Observable<UIImage>
        let nicknameTextChanged: Observable<String>
        let saveButtonTapped: Observable<Void>
    }
    
    struct Output {
        let currentProfile: Driver<UserProfile?>
        let nicknameValidation: Driver<NicknameValidation>
        let saveSuccess: Signal<Void>
        let saveError: Signal<Error>
    }
    
    // MARK: - Init
    init(
        getUserProfileUseCase: GetUserProfileUseCase,
        updateProfileImageUseCase: UpdateProfileImageUseCase,
        updateNicknameUseCase: UpdateNicknameUseCase
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.updateProfileImageUseCase = updateProfileImageUseCase
        self.updateNicknameUseCase = updateNicknameUseCase
        super.init()
        
        loadCurrentProfile()
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        
        // 이미지 선택 처리
        input.imageSelected
            .bind(with: self) { owner, image in
                owner.updateProfileImage(image)
            }
            .disposed(by: disposeBag)
        
        // 닉네임 입력 시 실시간 유효성 검사
        input.nicknameTextChanged
            .bind(with: self) { owner, nickname in
                owner.validateNickname(nickname)
            }
            .disposed(by: disposeBag)
        
        // 저장 버튼 탭 처리
        input.saveButtonTapped
            .withLatestFrom(input.nicknameTextChanged)
            .bind(with: self) { owner, nickname in
                owner.saveProfile(nickname: nickname)
            }
            .disposed(by: disposeBag)
        
        return Output(
            currentProfile: currentProfileRelay.asDriver(),
            nicknameValidation: nicknameValidationRelay.asDriver(),
            saveSuccess: saveSuccessRelay.asSignal(),
            saveError: saveErrorRelay.asSignal()
        )
    }
    
    // MARK: - Private Methods
    
    // 현재 프로필 정보 로드
    private func loadCurrentProfile() {
        let profile = getUserProfileUseCase.execute(())
        currentProfileRelay.accept(profile)
        
        if let nickname = profile?.nickname {
            validateNickname(nickname)
        }
    }
    
    // 프로필 이미지 업데이트
    private func updateProfileImage(_ image: UIImage) {
        let result = updateProfileImageUseCase.execute(image)
        
        switch result {
        case .success:
            // 프로필 정보 다시 로드하여 UI 업데이트
            loadCurrentProfile()
            
        case .failure(let error):
            saveErrorRelay.accept(error)
        }
    }
    
    // 닉네임 유효성 검사
    private func validateNickname(_ nickname: String) {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedNickname.isEmpty {
            nicknameValidationRelay.accept(.empty)
        } else if trimmedNickname.count > 10 {
            nicknameValidationRelay.accept(.tooLong)
        } else {
            nicknameValidationRelay.accept(.valid)
        }
    }
    
    // 프로필 저장 (닉네임만)
    private func saveProfile(nickname: String) {
        // 유효성 검사
        guard nicknameValidationRelay.value.isValid else {
            return
        }
        
        // 닉네임 업데이트
        let result = updateNicknameUseCase.execute(nickname)
        
        switch result {
        case .success:
            saveSuccessRelay.accept(())
            
        case .failure(let error):
            saveErrorRelay.accept(error)
        }
    }
}

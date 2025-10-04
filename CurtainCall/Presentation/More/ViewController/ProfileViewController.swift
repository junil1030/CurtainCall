//
//  ProfileViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa

final class ProfileEditViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: ProfileEditViewModel
    private let profileEditView = ProfileEditView()
    private let disposeBag = DisposeBag()
    
    // PHPicker delegate를 강하게 참조하기 위한 프로퍼티
    private var pickerDelegate: PHPickerDelegateWrapper?
    
    // MARK: - UI Components
    private lazy var saveBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "저장",
            style: .done,
            target: nil,
            action: nil
        )
        button.tintColor = .ccPrimary
        return button
    }()
    
    // MARK: - Init
    init(viewModel: ProfileEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        view = profileEditView
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.title = "프로필 편집"
        navigationItem.rightBarButtonItem = saveBarButton
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = ProfileEditViewModel.Input(
            imageSelected: profileEditView.imagePickerButtonTapped
                .flatMap { [weak self] _ -> Observable<UIImage> in
                    guard let self = self else { return .empty() }
                    return self.presentImagePicker()
                },
            nicknameTextChanged: profileEditView.nicknameText,
            saveButtonTapped: saveBarButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 현재 프로필 정보 바인딩
        output.currentProfile
            .drive(with: self) { owner, profile in
                owner.profileEditView.configure(with: profile)
                if let _ = profile?.nickname {
                    owner.profileEditView.nicknameTextField.sendActions(for: .editingChanged)
                }
            }
            .disposed(by: disposeBag)
        
        // 닉네임 유효성 검사 결과 바인딩
        output.nicknameValidation
            .drive(with: self) { owner, validation in
                owner.profileEditView.showValidationMessage(validation.message)
                owner.saveBarButton.isEnabled = validation.isValid
            }
            .disposed(by: disposeBag)
        
        // 닉네임 입력 시 미리보기 업데이트
        profileEditView.nicknameText
            .bind(with: self) { owner, nickname in
                owner.profileEditView.updatePreviewNickname(nickname)
            }
            .disposed(by: disposeBag)
        
        // 저장 성공
        output.saveSuccess
            .emit(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        // 저장 실패
        output.saveError
            .emit(with: self) { owner, error in
                owner.showErrorAlert(message: error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    
    /// PHPickerViewController 표시 및 이미지 선택 Observable 반환
    private func presentImagePicker() -> Observable<UIImage> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            
            let delegate = PHPickerDelegateWrapper { [weak self] results in
                guard let self = self else {
                    observer.onCompleted()
                    return
                }
                
                guard let result = results.first else {
                    observer.onCompleted()
                    self.pickerDelegate = nil
                    return
                }
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            observer.onError(error)
                            self.pickerDelegate = nil
                            return
                        }
                        
                        if let image = object as? UIImage {
                            observer.onNext(image)
                        }
                        observer.onCompleted()
                        self.pickerDelegate = nil
                    }
                }
            }
            
            self.pickerDelegate = delegate
            picker.delegate = delegate
            
            self.present(picker, animated: true)
            
            return Disposables.create {
                picker.dismiss(animated: true)
            }
        }
    }
    
    /// 에러 알럿 표시
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate Wrapper

/// PHPickerViewController의 Delegate를 클로저 기반으로 처리하기 위한 래퍼
private class PHPickerDelegateWrapper: NSObject, PHPickerViewControllerDelegate {
    private let completion: ([PHPickerResult]) -> Void
    
    init(completion: @escaping ([PHPickerResult]) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        completion(results)
    }
}

//
//  ProfileEditViewController.swift
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
    
    // MARK: - Subjects
    private let viewWillAppearSubject = PublishSubject<Void>()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext(())
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.title = "프로필 편집"
        navigationItem.rightBarButtonItem = saveBarButton
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = ProfileEditViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            imageSelected: profileEditView.imagePickerButtonTapped
                .flatMap { [weak self] _ -> Observable<UIImage> in
                    guard let self = self else { return .empty() }
                    return self.presentImagePicker()
                },
            nicknameTextChanged: profileEditView.nicknameText,
            saveButtonTapped: saveBarButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 현재 프로필 정보로 초기화 (화면 진입 시 한 번만)
        output.currentProfile
            .compactMap { $0 }
            .asObservable()
            .take(1)  // 첫 번째 값만 받음
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { owner, profile in
                owner.profileEditView.configure(with: profile)
            }
            .disposed(by: disposeBag)
        
        // 이미지 선택 시 미리보기만 업데이트
        output.selectedImage
            .compactMap { $0 }
            .drive(with: self) { owner, image in
                owner.profileEditView.updateProfileImage(image)
                owner.profileEditView.updatePreviewImage(image)
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
            
            let delegate = PHPickerDelegateWrapper { results in
                guard let result = results.first else {
                    observer.onCompleted()
                    return
                }
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    
                    if let image = object as? UIImage {
                        observer.onNext(image)
                    }
                    observer.onCompleted()
                }
            }
            
            self.pickerDelegate = delegate
            picker.delegate = delegate
            
            self.present(picker, animated: true)
            
            return Disposables.create()
        }
    }
    
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
private final class PHPickerDelegateWrapper: NSObject, PHPickerViewControllerDelegate {
    
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

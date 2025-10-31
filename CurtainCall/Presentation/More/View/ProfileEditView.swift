//
//  ProfileEditView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ProfileEditView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    // 스크롤뷰
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let contentView = UIView()
    
    // 프로필 이미지 섹션
    private let profileImageContainerView = UIView()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .ccSecondary
        imageView.layer.cornerRadius = 60
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .ccPrimary
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let cameraIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.circle.fill")
        imageView.tintColor = .ccPrimary
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
    
    let imagePickerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        return button
    }()
    
    // 닉네임 섹션
    private let nicknameContainerView = UIView()
    
    private let nicknameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = .ccTitle3Bold
        label.textColor = .ccPrimaryText
        return label
    }()
    
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "닉네임을 입력해주세요"
        textField.font = .ccBody
        textField.textColor = .ccPrimaryText
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.ccSeparator.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    let validationLabel: UILabel = {
        let label = UILabel()
        label.font = .ccFootnote
        label.textColor = .systemRed
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()
    
    // 미리보기 섹션
    private let previewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "미리보기"
        label.font = .ccTitle3Bold
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let previewProfileView = ProfileExperienceView()
    
    // MARK: - Observables
    var imagePickerButtonTapped: Observable<Void> {
        return imagePickerButton.rx.tap.asObservable()
    }
    
    var nicknameText: Observable<String> {
        return nicknameTextField.rx.text.orEmpty.asObservable()
    }
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 프로필 이미지 섹션
        contentView.addSubview(profileImageContainerView)
        profileImageContainerView.addSubview(profileImageView)
        profileImageContainerView.addSubview(cameraIconView)
        profileImageContainerView.addSubview(imagePickerButton)
        
        // 닉네임 섹션
        contentView.addSubview(nicknameContainerView)
        nicknameContainerView.addSubview(nicknameTitleLabel)
        nicknameContainerView.addSubview(nicknameTextField)
        nicknameContainerView.addSubview(validationLabel)
        
        // 미리보기 섹션
        contentView.addSubview(previewTitleLabel)
        contentView.addSubview(previewProfileView)
    }
    
    override func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 프로필 이미지 섹션
        profileImageContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cameraIconView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        imagePickerButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 닉네임 섹션
        nicknameContainerView.snp.makeConstraints { make in
            make.top.equalTo(profileImageContainerView.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        nicknameTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        
        validationLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // 미리보기 섹션
        previewTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameContainerView.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        previewProfileView.snp.makeConstraints { make in
            make.top.equalTo(previewTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(32)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
    }
    
    // MARK: - Public Methods
    
    // 프로필 이미지 업데이트
    func updateProfileImage(_ image: UIImage) {
        profileImageView.image = image
        previewProfileView.updateProfileImage(image)
    }
    
    // 닉네임 유효성 검사 메시지 표시
    func showValidationMessage(_ message: String?) {
        if let message = message {
            validationLabel.text = message
            validationLabel.isHidden = false
            nicknameTextField.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            validationLabel.isHidden = true
            nicknameTextField.layer.borderColor = UIColor.ccSeparator.cgColor
        }
    }
    
    /// 미리보기 이미지만 업데이트
    func updatePreviewImage(_ image: UIImage) {
        previewProfileView.updateProfileImage(image)
    }
    
    // 미리보기 닉네임 업데이트
    func updatePreviewNickname(_ nickname: String) {
        let displayNickname = nickname.isEmpty ? "닉네임" : nickname
        previewProfileView.updateNickname(displayNickname)
    }
    
    // 현재 프로필 정보로 초기화
    func configure(with profile: UserProfile?) {
        guard let profile = profile else { return }
        
        nicknameTextField.text = profile.nickname
        
        // 프로필 이미지 로드
        if !profile.profileImageURL.isEmpty {
            let container = DIContainer.shared
            let imageStorage = container.resolve(ImageStorageProtocol.self)
            if let image = imageStorage.loadProfileImage(from: profile.profileImageURL) {
                profileImageView.image = image
            } else {
                profileImageView.image = UIImage(systemName: "person.circle.fill")
                profileImageView.tintColor = .ccPrimary
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .ccPrimary
        }
        
        // 미리보기 초기화
        previewProfileView.configure(nickname: profile.nickname, profileImageURL: profile.profileImageURL)
    }
}

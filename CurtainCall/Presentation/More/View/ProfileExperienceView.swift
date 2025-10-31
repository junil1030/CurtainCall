//
//  ProfileExperienceView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit
import RxSwift
import SnapKit

final class ProfileExperienceView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let profileTapSubject = PublishSubject<Void>()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .ccPrimary
        view.clipsToBounds = true
        return view
    }()
    
    // 프로필 섹션
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .ccSecondary
        imageView.layer.cornerRadius = 28
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .ccPrimary
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .ccTitle2Bold
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private let profileStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Observables
    var profileTapped: Observable<Void> {
        return profileTapSubject.asObservable()
    }
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(containerView)
        
        containerView.addSubview(profileImageView)
        containerView.addSubview(profileStackView)
        
        profileStackView.addArrangedSubview(nicknameLabel)
        profileStackView.addArrangedSubview(subtitleLabel)
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 프로필 이미지
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(56)
            make.bottom.equalToSuperview().inset(20).priority(.high)
        }
        
        // 프로필 텍스트 스택
        profileStackView.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(20).priority(.high)
            make.centerY.equalTo(profileImageView)
        }
        
        containerView.snp.makeConstraints { make in
            make.height.equalTo(96)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .clear
        setupTapGesture()
    }
    
    // MARK: - Setup Methods
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event
            .map { _ in () }
            .bind(to: profileTapSubject)
            .disposed(by: disposeBag)
        
        containerView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Public Methods
    
    // 탭 제스처 활성화 (더보기 화면용)
    func enableTapGesture() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event
            .map { _ in () }
            .bind(to: profileTapSubject)
            .disposed(by: disposeBag)
        
        containerView.addGestureRecognizer(tapGesture)
    }
    
    // 프로필 정보 업데이트
    func configure(nickname: String, profileImageURL: String) {
        nicknameLabel.text = nickname
        
        // 프로필 이미지 로드
        if !profileImageURL.isEmpty {
            let container = DIContainer.shared
            let imageStorage = container.resolve(ImageStorageProtocol.self)
            if let image = imageStorage.loadProfileImage(from: profileImageURL) {
                profileImageView.image = image
            } else {
                profileImageView.image = UIImage(systemName: "person.circle.fill")
                profileImageView.tintColor = .ccPrimary
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .ccPrimary
        }
    }
    
    // 프로필 이미지만 업데이트
    func updateProfileImage(_ image: UIImage?) {
        if let image = image {
            profileImageView.image = image
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .ccPrimary
        }
    }
    
    // 닉네임만 업데이트
    func updateNickname(_ nickname: String) {
        nicknameLabel.text = nickname
    }
}

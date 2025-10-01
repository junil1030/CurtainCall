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
    
    // 경험치 섹션
    private let experienceContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.2)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCalloutBold
        label.textColor = .white
        return label
    }()
    
    private let experienceLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private let experienceBarBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .ccSeparator
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    private let experienceBarFill: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let remainingLabel: UILabel = {
        let label = UILabel()
        label.font = .ccFootnote
        label.textColor = .white.withAlphaComponent(0.9)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(containerView)
        
        containerView.addSubview(profileImageView)
        containerView.addSubview(profileStackView)
        containerView.addSubview(experienceContainerView)
        
        profileStackView.addArrangedSubview(nicknameLabel)
        profileStackView.addArrangedSubview(subtitleLabel)
        
        experienceContainerView.addSubview(levelLabel)
        experienceContainerView.addSubview(experienceLabel)
        experienceContainerView.addSubview(experienceBarBackground)
        experienceBarBackground.addSubview(experienceBarFill)
        experienceContainerView.addSubview(remainingLabel)
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 프로필 이미지
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(56).priority(.high)
        }
        
        // 프로필 텍스트 스택
        profileStackView.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(20).priority(.high)
            make.centerY.equalTo(profileImageView)
        }
        
        // 경험치 컨테이너
        experienceContainerView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20).priority(.high)
            make.bottom.equalToSuperview().inset(20)
        }
        
        // 레벨 라벨
        levelLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(12)
        }
        
        // 경험치 라벨
        experienceLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(12).priority(.high)
            make.leading.greaterThanOrEqualTo(levelLabel.snp.trailing).offset(8).priority(.high)
        }
        
        // 경험치 바 배경
        experienceBarBackground.snp.makeConstraints { make in
            make.top.equalTo(levelLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12).priority(.high)
            make.height.equalTo(8)
        }
        
        // 경험치 바 채움
        experienceBarFill.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8) // 초기값, 나중에 업데이트
        }
        
        // 남은 경험치 라벨
        remainingLabel.snp.makeConstraints { make in
            make.top.equalTo(experienceBarBackground.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12).priority(.high)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .clear
    }
    
    // MARK: - Public Methods
    func configure(with data: ProfileExperienceData) {
        nicknameLabel.text = data.nickname
        subtitleLabel.text = data.subtitle
        levelLabel.text = "Lv.\(data.level)"
        experienceLabel.text = "\(data.currentExp)/\(data.maxExp)"
        remainingLabel.text = "다음 레벨까지 \(data.remainingExp)편 남음"
        
        // 경험치 바 업데이트
        let progress = CGFloat(data.currentExp) / CGFloat(data.maxExp)
        experienceBarFill.snp.updateConstraints { make in
            make.width.equalToSuperview().multipliedBy(progress)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    func updateProfileImage(_ image: UIImage?) {
        profileImageView.image = image
    }
}

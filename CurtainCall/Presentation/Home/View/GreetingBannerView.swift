//
//  GreetingBannerView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import RxSwift
import SnapKit

final class GreetingBannerView: BaseView {
    
    // MARK: - Types
    private enum TimeOfDay {
        case morning      // 06:00 ~ 12:00
        case lunch        // 12:00 ~ 14:00
        case afternoon    // 14:00 ~ 18:00
        case evening      // 18:00 ~ 23:00
        case lateNight    // 23:00 ~ 06:00
        
        var greetings: [String] {
            switch self {
            case .morning:
                return [
                    "좋은 아침이에요",
                    "상쾌한 아침입니다",
                    "행복한 아침 되세요",
                    "오늘도 화이팅!"
                ]
            case .lunch:
                return [
                    "점심은 드셨나요?",
                    "맛있는 점심 시간이에요",
                    "오늘 점심 메뉴는?",
                    "활기찬 점심시간!"
                ]
            case .afternoon:
                return [
                    "오후도 힘내세요",
                    "느긋한 오후입니다",
                    "여유로운 오후에요",
                    "편안한 오후 보내세요"
                ]
            case .evening:
                return [
                    "즐거운 저녁이에요",
                    "오늘 하루 수고하셨어요",
                    "편안한 저녁 되세요",
                    "좋은 밤 되세요"
                ]
            case .lateNight:
                return [
                    "아직 안 주무세요?",
                    "조용한 밤이네요",
                    "편안한 밤 되세요",
                    "오늘도 수고하셨어요"
                ]
            }
        }
        
        var suggestions: [String] {
            switch self {
            case .morning:
                return [
                    "오늘은 어떤 공연을 만나볼까요?",
                    "아침부터 공연 찾기! 어때요?",
                    "오늘은 뮤지컬 어떠세요?"
                ]
            case .lunch:
                return [
                    "점심 후엔 공연 예매 어때요?",
                    "오늘은 연극 어떠신가요?",
                    "휴식 시간에 공연 찾아볼까요?"
                ]
            case .afternoon:
                return [
                    "오후엔 뮤지컬 어떠세요?",
                    "오늘은 어떤 공연을 볼까요?",
                    "이번 주말 공연 찾아볼까요?"
                ]
            case .evening:
                return [
                    "저녁 시간, 공연 어때요?",
                    "오늘은 연극 어떠신가요?",
                    "주말 공연 예매 어떠세요?"
                ]
            case .lateNight:
                return [
                    "내일 볼 공연 찾아볼까요?",
                    "이번 주말 공연은 어때요?",
                    "다음 주 공연 예매해볼까요?"
                ]
            }
        }
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.ccSecondary.cgColor,
            UIColor.ccPrimary.cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccBannerText
        label.numberOfLines = 1
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .ccTitle2Bold
        label.textColor = .ccBannerText
        label.numberOfLines = 1
        return label
    }()
    
    private let suggestionLabel: UILabel = {
        let label = UILabel()
        label.font = .ccSubheadline
        label.textColor = .ccBannerText
        label.numberOfLines = 1
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .ccSecondary
        imageView.layer.cornerRadius = 28
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        // TODO: 사용자 프로필 이미지 연동
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .ccPrimary
        return imageView
    }()
    
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(containerView)
        containerView.layer.addSublayer(gradientLayer)
        containerView.addSubview(textStackView)
        containerView.addSubview(profileImageView)
        
        textStackView.addArrangedSubview(greetingLabel)
        textStackView.addArrangedSubview(nicknameLabel)
        textStackView.addArrangedSubview(suggestionLabel)
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(4)
//            make.height.equalTo(100)
        }
        
        textStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(profileImageView.snp.leading).offset(-16)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(56)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .clear
        updateGreeting()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = containerView.bounds
    }
    
    // MARK: - Private Methods
    private func updateGreeting() {
        let timeOfDay = getCurrentTimeOfDay()
        
        // 랜덤 인사말 선택
        let greeting = timeOfDay.greetings.randomElement() ?? "안녕하세요"
        greetingLabel.text = greeting
        
        // TODO: 실제 사용자 닉네임으로 변경
        nicknameLabel.text = "닉네임님!"
        
        // 랜덤 제안 문구 선택
        let suggestion = timeOfDay.suggestions.randomElement() ?? "오늘은 어떤 공연을 볼까요?"
        suggestionLabel.text = suggestion
    }
    
    private func getCurrentTimeOfDay() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<12:
            return .morning
        case 12..<14:
            return .lunch
        case 14..<18:
            return .afternoon
        case 18..<23:
            return .evening
        default:
            return .lateNight
        }
    }
    
    // MARK: - Public Methods
    func updateNickname(_ nickname: String) {
        nicknameLabel.text = "\(nickname)님!"
    }
    
    func updateProfileImage(_ image: UIImage?) {
        profileImageView.image = image
    }
}

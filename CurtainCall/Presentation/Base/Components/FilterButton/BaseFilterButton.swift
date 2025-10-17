//
//  BaseFilterButton.swift
//  CurtainCall
//
//  Created by 서준일 on 10/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class BaseFilterButton: UIButton {
    
    // MARK: - Constants
    private enum Metric {
        static let horizontalInset: CGFloat = 12
        static let verticalInset: CGFloat = 8
        static let stackSpacing: CGFloat = 4
        static let iconSize: CGFloat = 14
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    let filterTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccSubheadline
        label.textColor = .ccPrimaryText
        label.textAlignment = .center
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ccPrimaryText
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Metric.stackSpacing
        stack.alignment = .center
        stack.distribution = .fill
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    // MARK: - Observables
    private let selectedValueRelay = BehaviorRelay<Any?>(value: nil)
    private let isActiveRelay = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Public Observables
    var selectedValue: Observable<Any?> {
        return selectedValueRelay.asObservable()
    }
    
    var isActive: Observable<Bool> {
        return isActiveRelay.asObservable()
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupStyle()
        setupDefaultIcon()
        setupButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(filterTitleLabel)
        stackView.addArrangedSubview(iconImageView)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Metric.verticalInset)
            make.leading.trailing.equalToSuperview().inset(Metric.horizontalInset)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Metric.iconSize)
        }
    }
    
    private func setupStyle() {
        // 캡슐 모양
        layer.cornerRadius = Metric.cornerRadius
        layer.borderWidth = Metric.borderWidth
        layer.borderColor = UIColor.systemGray4.cgColor
        backgroundColor = .ccBackground
        
        // 섀도우 제거
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowOpacity = 0
        layer.shadowOffset = .zero
        layer.shadowRadius = 0
    }
    
    private func setupDefaultIcon() {
        iconImageView.image = getDefaultIcon()
    }
    
    // MARK: - Public Methods
    
    /// 버튼 타이틀 업데이트
    func updateTitle(_ title: String) {
        filterTitleLabel.text = title
    }
    
    /// 아이콘 업데이트
    func updateIcon(_ image: UIImage?) {
        iconImageView.image = image
    }
    
    /// 선택된 값 업데이트 (하위 클래스에서 사용)
    func updateSelectedValue(_ value: Any?) {
        selectedValueRelay.accept(value)
    }
    
    /// 활성화 상태 업데이트 (하위 클래스에서 사용)
    func updateActiveState(_ isActive: Bool) {
        isActiveRelay.accept(isActive)
    }
    
    /// 타이틀 레이블 숨김/표시
    func setTitleHidden(_ hidden: Bool) {
        filterTitleLabel.isHidden = hidden
    }
    
    // MARK: - Abstract Methods (하위 클래스에서 구현)
    
    /// 기본 아이콘 반환
    /// - Returns: 버튼 타입에 맞는 기본 아이콘
    func getDefaultIcon() -> UIImage? {
        // 하위 클래스에서 오버라이드
        return nil
    }
    
    /// 버튼 액션 설정
    /// - 하위 클래스에서 각 버튼별 동작을 구현
    func setupButtonAction() {
        // 하위 클래스에서 오버라이드
    }
}

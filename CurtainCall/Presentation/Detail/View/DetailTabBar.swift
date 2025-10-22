//
//  DetailTabBar.swift
//  CurtainCall
//
//  Created by 서준일 on 10/21/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DetailTabBar: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var currentTab: DetailTab = .info
    
    // MARK: - Subjects
    private let tabSelectedSubject = PublishSubject<DetailTab>()
    
    // MARK: - Observables
    var tabSelected: Observable<DetailTab> {
        return tabSelectedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    private lazy var tabButtons: [UIButton] = {
        return DetailTab.allCases.map { tab in
            let button = UIButton()
            button.setTitle(tab.title, for: .normal)
            button.setTitleColor(.ccSecondaryText, for: .normal)
            button.setTitleColor(.ccPrimaryText, for: .selected)
            button.titleLabel?.font = .ccCallout
            button.tag = tab.rawValue
            return button
        }
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccPrimary
        view.layer.cornerRadius = 1.5
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Lifecycle
    override func setupHierarchy() {
        addSubview(stackView)
        addSubview(separatorView)
        addSubview(underlineView)
        
        tabButtons.forEach { stackView.addArrangedSubview($0) }
    }
    
    override func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        underlineView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(3)
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        
        // 초기 underline 위치 설정
        updateUnderlinePosition(for: currentTab, animated: false)
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
        
        // 초기 선택 상태 설정
        updateButtonStates(for: currentTab)
        
        // 버튼 탭 이벤트
        tabButtons.forEach { button in
            button.rx.tap
                .map { DetailTab(rawValue: button.tag) ?? .info }
                .subscribe(with: self) { owner, tab in
                    owner.selectTab(tab, animated: true)
                }
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Public Methods
    func selectTab(_ tab: DetailTab, animated: Bool = true) {
        guard currentTab != tab else { return }
        
        currentTab = tab
        updateButtonStates(for: tab)
        updateUnderlinePosition(for: tab, animated: animated)
        tabSelectedSubject.onNext(tab)
    }
    
    // MARK: - Private Methods
    private func updateButtonStates(for tab: DetailTab) {
        tabButtons.forEach { button in
            let isSelected = button.tag == tab.rawValue
            button.isSelected = isSelected
            button.titleLabel?.font = isSelected ? .ccCalloutBold : .ccCallout
        }
    }
    
    private func updateUnderlinePosition(for tab: DetailTab, animated: Bool) {
        guard let selectedButton = tabButtons.first(where: { $0.tag == tab.rawValue }) else { return }
        
        let duration = animated ? 0.25 : 0
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            self.underlineView.snp.remakeConstraints { make in
                make.top.equalTo(self.separatorView.snp.bottom)
                make.bottom.equalToSuperview()
                make.leading.equalTo(selectedButton.snp.leading)
                make.trailing.equalTo(selectedButton.snp.trailing)
                make.height.equalTo(3)
            }
            self.layoutIfNeeded()
        }
    }
}

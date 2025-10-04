//
//  FilterButton.swift
//  CurtainCall
//
//  Created by 서준일 on 9/28/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class FilterButton: UIButton {
    
    // MARK: - Types
    enum ButtonType {
        case reset
        case dropdown(items: [DropdownItem])
        case datePicker(allowFuture: Bool = false)
        case timePicker
    }
    
    struct DropdownItem {
        let title: String
        let value: Any
        
        init(title: String, value: Any) {
            self.title = title
            self.value = value
        }
    }
    
    // MARK: - Properties
    private let filterButtonType: ButtonType
    private let disposeBag = DisposeBag()
    private var currentSelectedDate: Date = Date().yesterday
    
    // MARK: - UIComponents
    private let title: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccPrimaryText
        label.textAlignment = .center
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ccSecondaryText
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
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
    init(type: ButtonType, title: String, icon: UIImage? = nil) {
        self.filterButtonType = type
        super.init(frame: .zero)
        
        setupUI()
        setupStyle()
        setupTitle(title)
        setupIcon(icon)
        setupButtonAction()
        bindObservables()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(title)
        
        if case .reset = filterButtonType {
            // 초기화 버튼은 아이콘만
            stackView.addArrangedSubview(iconImageView)
        } else {
            // 드롭다운 버튼들은 텍스트 + 아이콘
            stackView.addArrangedSubview(iconImageView)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
    }
    
    private func setupStyle() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.ccSeparator.cgColor
        backgroundColor = .ccBackground
        
        // 그림자 효과
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }
    
    private func setupTitle(_ titleText: String) {
        if case .reset = filterButtonType {
            title.isHidden = true
        } else {
            title.text = titleText
        }
    }
    
    private func setupIcon(_ icon: UIImage?) {
        switch filterButtonType {
        case .reset:
            iconImageView.image = UIImage(systemName: "arrow.trianglehead.clockwise.rotate.90")
        case .dropdown, .datePicker, .timePicker:
            iconImageView.image = UIImage(systemName: "chevron.down")
        }
    }
    
    private func setupButtonAction() {
        switch filterButtonType {
        case .reset:
            rx.tap
                .subscribe(with: self) { owner, _ in
                    owner.selectedValueRelay.accept("reset")
                }
                .disposed(by: disposeBag)
                
        case .dropdown(let items):
            setupDropdownMenu(items: items)
            
        case .datePicker:
            rx.tap
                .subscribe(with: self) { owner, _ in
                    owner.handleDatePickerAction()
                }
                .disposed(by: disposeBag)
            
        case .timePicker:
            rx.tap
                .subscribe(with: self) { owner, _ in
                    owner.handleTimePickerAction()
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func setupDropdownMenu(items: [DropdownItem]) {
        changesSelectionAsPrimaryAction = false
        showsMenuAsPrimaryAction = true
        
        let menuActions = items.map { item in
            UIAction(title: item.title) { [weak self] _ in
                self?.handleMenuSelection(item)
            }
        }
        
        menu = UIMenu(children: menuActions)
    }
    
    private func bindObservables() {
        isActive
            .subscribe(with: self) { owner, isHighlighted in
                owner.updateAppearance(isHighlighted: isHighlighted)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    private func handleMenuSelection(_ item: DropdownItem) {
        updateTitle(item.title)
        selectedValueRelay.accept(item.value)
    }
    
    private func handleDatePickerAction() {
        guard let parentViewController = findParentViewController() else { return }
        
        let allowFuture: Bool
        if case .datePicker(let allowFutureValue) = filterButtonType {
            allowFuture = allowFutureValue
        } else {
            allowFuture = false
        }
        
        let datePickerVC = CustomDatePickerView(initialDate: currentSelectedDate, allowFuture: allowFuture)
        
        datePickerVC.selectedDate
            .bind(with: self) { owner, date in
                owner.currentSelectedDate = date
                owner.handleDateSelection(date)
            }
            .disposed(by: disposeBag)
        
        // Modal로 표시
        if let sheet = datePickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        parentViewController.present(datePickerVC, animated: true)
    }
    
    private func handleDateSelection(_ date: Date) {
        selectedValueRelay.accept(date)
    }
    
    private func handleTimePickerAction() {
        guard let parentViewController = findParentViewController() else { return }
        
        let timePickerVC = CustomTimePickerView(initialDate: Date())
        
        timePickerVC.selectedTime
            .bind(with: self) { owner, time in
                owner.currentSelectedDate = time
                owner.handleDateSelection(time)
            }
            .disposed(by: disposeBag)
        
        if let sheet = timePickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        parentViewController.present(timePickerVC, animated: true)
    }
    
    private func findParentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    // MARK: - UI Updates
    private func updateAppearance(isHighlighted: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.layer.borderColor = isHighlighted ?
                UIColor.ccPrimary.cgColor : UIColor.ccSeparator.cgColor
            self?.backgroundColor = isHighlighted ?
                UIColor.ccSecondary : UIColor.ccBackground
        }
    }
    
    private func updateTitle(_ newTitle: String) {
        title.text = newTitle
    }
    
    // MARK: - Public Methods
    func setHighlighted(_ highlighted: Bool) {
        isActiveRelay.accept(highlighted)
    }
    
    func setTitle(_ title: String) {
        updateTitle(title)
    }
    
    func setSelectedValue(_ value: Any?) {
        selectedValueRelay.accept(value)
    }
}

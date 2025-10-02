//
//  CCButton.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import RxCocoa

class CCButton: UIButton {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Observables
    private let isSelectedRelay = BehaviorRelay<Bool>(value: false)
    
    var isSelectedObservable: Observable<Bool> {
        return isSelectedRelay.asObservable()
    }
    
    var isSelectedValue: Bool {
        return isSelectedRelay.value
    }
    
    // MARK: - Configuration
    struct Style {
        let title: String
        let font: UIFont
        let normalBackgroundColor: UIColor
        let selectedBackgroundColor: UIColor
        let normalTextColor: UIColor
        let selectedTextColor: UIColor
        let normalBorderColor: UIColor
        let selectedBorderColor: UIColor
        let borderWidth: CGFloat
        let cornerRadius: CGFloat
        let contentInsets: UIEdgeInsets
        
        static let `default` = Style(
            title: "",
            font: .ccCallout,
            normalBackgroundColor: .ccBackground,
            selectedBackgroundColor: .ccPrimary,
            normalTextColor: .ccPrimaryText,
            selectedTextColor: .white,
            normalBorderColor: .ccSeparator,
            selectedBorderColor: .ccPrimary,
            borderWidth: 1,
            cornerRadius: 8,
            contentInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        )
    }
    
    private var buttonStyle: Style
    
    // MARK: - Init
    init(style: Style = .default) {
        self.buttonStyle = style
        super.init(frame: .zero)
        
        setupStyle()
        setupBind()
    }
    
    convenience init(title: String) {
        var style = Style.default
        style = Style(
            title: title,
            font: style.font,
            normalBackgroundColor: style.normalBackgroundColor,
            selectedBackgroundColor: style.selectedBackgroundColor,
            normalTextColor: style.normalTextColor,
            selectedTextColor: style.selectedTextColor,
            normalBorderColor: style.normalBorderColor,
            selectedBorderColor: style.selectedBorderColor,
            borderWidth: style.borderWidth,
            cornerRadius: style.cornerRadius,
            contentInsets: style.contentInsets
        )
        self.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupStyle() {
        var config = UIButton.Configuration.plain()
        config.title = buttonStyle.title
        config.baseForegroundColor = buttonStyle.normalTextColor
        config.contentInsets = NSDirectionalEdgeInsets(
            top: buttonStyle.contentInsets.top,
            leading: buttonStyle.contentInsets.left,
            bottom: buttonStyle.contentInsets.bottom,
            trailing: buttonStyle.contentInsets.right
        )
        
        self.configuration = config
        
        titleLabel?.font = buttonStyle.font
        
        layer.cornerRadius = buttonStyle.cornerRadius
        layer.borderWidth = buttonStyle.borderWidth
        
        updateAppearance(isSelected: false)
    }
    
    private func setupBind() {
        rx.tap
            .subscribe(with: self) { owner, _ in
                owner.toggleSelection()
            }
            .disposed(by: disposeBag)
        
        isSelectedRelay
            .subscribe(with: self) { owner, isSelected in
                owner.updateAppearance(isSelected: isSelected)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Methods
    func setSelected(_ isSelected: Bool) {
        isSelectedRelay.accept(isSelected)
    }
    
    func toggleSelection() {
        let newValue = !isSelectedRelay.value
        isSelectedRelay.accept(newValue)
    }
    
    func setTitle(_ title: String) {
        if var config = self.configuration {
            config.title = title
            self.configuration = config
        }
    }
    
    // MARK: - Private Methods
    private func updateAppearance(isSelected: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = isSelected ?
                self.buttonStyle.selectedBackgroundColor :
                self.buttonStyle.normalBackgroundColor
            
            self.layer.borderColor = isSelected ?
                self.buttonStyle.selectedBorderColor.cgColor :
                self.buttonStyle.normalBorderColor.cgColor
            
            if var config = self.configuration {
                config.baseForegroundColor = isSelected ?
                    self.buttonStyle.selectedTextColor :
                    self.buttonStyle.normalTextColor
                self.configuration = config
            }
        }
    }
    
//    // MARK: - Override
//    override var intrinsicContentSize: CGSize {
//        // UIButton.Configuration을 사용하면 자동으로 크기 계산됨
//        let size = super.intrinsicContentSize
//        return size
//    }
}

//
//  CustomDatePickerView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CustomDatePickerView: BaseViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let allowFuture: Bool
    private let initialDate: Date
    
    // MARK: - Stream
    private let selectedDateRelay = PublishRelay<Date>()
    
    // MARK: - Observable
    var selectedDate: Observable<Date> {
        return selectedDateRelay.asObservable()
    }
    
    // MARK: - UIComponenets
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.locale = Locale(identifier: "ko_KR")
        picker.timeZone = TimeZone(identifier: "Asia/Seoul")
        picker.date = initialDate
        picker.tintColor = .ccAccent
        
        if !allowFuture {
            let now = Date()
            let currentHour = Calendar.current.component(.hour, from: now)
            let maxDate = currentHour >= 12 ? now : now.daysBefore(1)
            picker.maximumDate = maxDate
        }
        
        return picker
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ccPrimary
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .ccBodyBold
        return button
    }()
    
    // MARK: - Init
    init(initialDate: Date = Date().yesterday, allowFuture: Bool = false) {
        self.initialDate = initialDate
        self.allowFuture = allowFuture
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - BaseViewController Override
    override func setupLayout() {
        super.setupLayout()

        view.addSubview(datePicker)
        view.addSubview(confirmButton)
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(44)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-12)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        view.backgroundColor = .ccBackground
    }
    
    override func setupBind() {
        super.setupBind()
        
        confirmButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.selectedDateRelay.accept(owner.datePicker.date)
            }
            .disposed(by: disposeBag)
    }
}

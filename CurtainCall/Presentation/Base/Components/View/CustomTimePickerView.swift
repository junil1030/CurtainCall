//
//  CustomTimePickerView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CustomTimePickerView: BaseViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let initialDate: Date
    
    // MARK: - Stream
    private let selectedTimeRelay = PublishRelay<Date>()
    
    // MARK: - Observable
    var selectedTime: Observable<Date> {
        return selectedTimeRelay.asObservable()
    }
    
    // MARK: - UIComponents
    private lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")
        picker.timeZone = TimeZone(identifier: "Asia/Seoul")
        picker.date = initialDate
        picker.tintColor = .ccAccent
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
    init(initialDate: Date = Date()) {
        self.initialDate = initialDate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - BaseViewController Override
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(timePicker)
        view.addSubview(confirmButton)
        
        timePicker.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(timePicker.snp.bottom).offset(12)
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
                owner.selectedTimeRelay.accept(owner.timePicker.date)
            }
            .disposed(by: disposeBag)
    }
}

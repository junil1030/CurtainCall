//
//  DatePickerView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/28/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DatePickerView: UIView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 20
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "날짜 선택"
        label.font = .ccTitle3Bold
        label.textColor = .ccPrimaryText
        label.textAlignment = .center
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ko_KR")
        picker.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        // 최대 날짜 설정 (오후 12시 기준)
        let now = Date()
        let currentHour = Calendar.current.component(.hour, from: now)
        let maxDate = currentHour >= 12 ? now : now.daysBefore(1)
        picker.maximumDate = maxDate
        
        return picker
    }()
    
    // MARK: - Observables
    private let selectedDateRelay = PublishRelay<Date>()
    
    // MARK: - Public Observables
    var selectedDate: Observable<Date> {
        return selectedDateRelay.asObservable()
    }
    
    // MARK: - Init
    init(initialDate: Date = Date().yesterday) {
        super.init(frame: .zero)
        
        datePicker.date = initialDate
        setupUI()
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .black.withAlphaComponent(0.4)
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(datePicker)
        
        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(120)
            make.width.equalTo(300)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func bindActions() {
        var previousDate = datePicker.date
        
        // 날짜 변경 시 바로 선택 완료
        datePicker.rx.date
            .skip(1) // 초기값 스킵
            .subscribe(with: self) { owner, selectedDate in
                let calendar = Calendar.current
                
                // 이전 날짜와 새로운 날짜의 day 컴포넌트 비교
                let previousDay = calendar.component(.day, from: previousDate)
                let selectedDay = calendar.component(.day, from: selectedDate)
                
                // 일(day)이 실제로 바뀌었을 때만 선택 완료
                if previousDay != selectedDay {
                    owner.selectedDateRelay.accept(selectedDate)
                }
                
                // 이전 날짜 업데이트
                previousDate = selectedDate
            }
            .disposed(by: disposeBag)
        
        // 배경 터치로 취소
        let tapGesture = UITapGestureRecognizer()
        addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(with: self) { owner, gesture in
                let location = gesture.location(in: owner)
                if !owner.containerView.frame.contains(location) {
                    owner.hide()
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Animation Methods
    func show(in parentView: UIView) {
        parentView.addSubview(self)
        
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 애니메이션으로 등장
        alpha = 0.0
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.alpha = 1.0
            self.containerView.transform = .identity
        }
    }
    
    func hide(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
            self.alpha = 0.0
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
}

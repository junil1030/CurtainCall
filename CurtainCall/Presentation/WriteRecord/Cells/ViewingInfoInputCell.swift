//
//  ViewingInfoInputCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import SnapKit

final class ViewingInfoInputCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Subjects
    private let dateButtonTappedSubject = PublishSubject<Date>()
    private let timeButtonTappedSubject = PublishSubject<Date>()
    private let companionSelectedSubject = PublishSubject<String>()
    private let seatTextChangedSubject = PublishSubject<String>()
    
    // MARK: - Observables
    var dateButtonTapped: Observable<Date> {
        return dateButtonTappedSubject.asObservable()
    }
    
    var timeButtonTapped: Observable<Date> {
        return timeButtonTappedSubject.asObservable()
    }
    
    var companionSelected: Observable<String> {
        return companionSelectedSubject.asObservable()
    }
    
    var seatTextChanged: Observable<String> {
        return seatTextChangedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        return stack
    }()
    
    // 관람 날짜 행
    private let dateRowStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private let dateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "관람 날짜"
        label.font = .ccBodyBold
        label.textColor = .ccPrimaryText
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var dateSelectorButton: DatePickerFilterButton = {
        return DatePickerFilterButton(allowFuture: false, initialDate: Date())
    }()
    
    // 관람 시간 행
    private let timeRowStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private let timeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "관람 시간"
        label.font = .ccBodyBold
        label.textColor = .ccPrimaryText
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var timeSelectorButton: TimePickerFilterButton = {
        return TimePickerFilterButton(initialTime: Date())
    }()
    
    // 함께한 사람 행
    private let companionRowStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()
    
    private let companionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "함께한 사람"
        label.font = .ccBodyBold
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let companionButtonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private lazy var aloneButton = CCButton(title: "혼자")
    private lazy var friendButton = CCButton(title: "친구")
    private lazy var familyButton = CCButton(title: "가족")
    private lazy var loverButton = CCButton(title: "연인")
    private lazy var otherButton = CCButton(title: "기타")
    
    private lazy var companionButtons: [CCButton] = [
        aloneButton, friendButton, familyButton, loverButton, otherButton
    ]
    
    // 좌석 행
    private let seatRowStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private let seatTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "좌석"
        label.font = .ccBodyBold
        label.textColor = .ccPrimaryText
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let seatTextView: UITextView = {
        let textView = UITextView()
        textView.font = .ccCallout
        textView.textColor = .ccPrimaryText
        textView.backgroundColor = .ccBackground
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.ccSeparator.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.isScrollEnabled = false
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "예: 1층 R석 12열 8번"
        label.font = .ccCallout
        label.textColor = .ccSecondaryText
        return label
    }()
    
    // MARK: - Override Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        seatTextView.text = ""
        placeholderLabel.isHidden = false
        
        // 모든 버튼 선택 해제
        companionButtons.forEach { $0.setSelected(false) }
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerStackView)
        
        // 날짜 행
        dateRowStackView.addArrangedSubview(dateTitleLabel)
        dateRowStackView.addArrangedSubview(dateSelectorButton)
        
        // 시간 행
        timeRowStackView.addArrangedSubview(timeTitleLabel)
        timeRowStackView.addArrangedSubview(timeSelectorButton)
        
        // 함께한 사람 행
        companionRowStackView.addArrangedSubview(companionTitleLabel)
        companionRowStackView.addArrangedSubview(companionButtonsStackView)
        
        companionButtons.forEach { button in
            companionButtonsStackView.addArrangedSubview(button)
        }
        
        // 좌석 행
        seatTextView.addSubview(placeholderLabel)
        seatRowStackView.addArrangedSubview(seatTitleLabel)
        seatRowStackView.addArrangedSubview(seatTextView)
        
        // 전체 스택뷰에 추가
        [dateRowStackView, timeRowStackView, companionRowStackView, seatRowStackView].forEach {
            containerStackView.addArrangedSubview($0)
        }
    }
    
    override func setupLayout() {
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        dateTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(90)
        }
        
        timeTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(90)
        }
        
        seatTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(90)
        }
        
        seatTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(44)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(12)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        setupBind()
        updateDateButton(date: Date())
    }
    
    private func setupBind() {
        
        // 날짜 버튼 탭
        dateSelectorButton.selectedValue
            .compactMap { $0 as? Date}
            .bind(with: self) { owner, date in
                owner.updateDateButton(date: date)
            }
            .disposed(by: disposeBag)
        
        // 시간 버튼 탭
        timeSelectorButton.selectedValue
            .compactMap { $0 as? Date }
            .bind(to: timeButtonTappedSubject)
            .disposed(by: disposeBag)
        
        // 함께한 사람 버튼들 처리
        setupCompanionButtons()
        
        // 좌석 텍스트 변경
        seatTextView.rx.text.orEmpty
            .do(onNext: { [weak self] text in
                self?.placeholderLabel.isHidden = !text.isEmpty
            })
            .bind(to: seatTextChangedSubject)
            .disposed(by: disposeBag)
    }
    
    private func setupCompanionButtons() {
        companionButtons.forEach { button in
            button.rx.tap
                .subscribe(with: self) { owner, _ in
                    // 다른 버튼들 선택 해제
                    owner.companionButtons.forEach { otherButton in
                        if otherButton !== button {
                            otherButton.setSelected(false)
                        }
                    }
                    
                    // 현재 버튼의 선택 상태 확인
                    let isSelected = button.isSelectedValue
                    button.setSelected(isSelected)
                    
                    // 선택된 경우에만 이벤트 전달
                    if isSelected, let title = button.titleLabel?.text {
                        owner.companionSelectedSubject.onNext(title)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Configure
    func configure(date: Date, time: Date, companion: String, seat: String) {
        print(date)
        // 날짜 설정
        updateDateButton(date: date)
        
        // 시간 설정
        updateTimeButton(time: time)
        
        // 동행인 설정
        companionButtons.forEach { button in
            if button.titleLabel?.text == companion {
                button.setSelected(true)
                companionSelectedSubject.onNext(companion)
            } else {
                button.setSelected(false)
            }
        }
        
        // 좌석 설정
        seatTextView.text = seat
        placeholderLabel.isHidden = !seat.isEmpty
        seatTextChangedSubject.onNext(seat)
    }
    
    // MARK: - Private Methods
    private func updateDateButton(date: Date) {
        let dateString = date.toDateWithWeekday
        dateSelectorButton.updateTitle(dateString)
    }
    
    private func updateTimeButton(time: Date) {
        let timeString = time.toTime24Hour
        timeSelectorButton.updateTitle(timeString)
    }
}

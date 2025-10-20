//
//  FilterButtonCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class FilterButtonCell: BaseCollectionViewCell {
    
    // MARK: - Types
    enum DateRangeType: String, CaseIterable {
        case daily = "일간"
        case weekly = "주간"
        case monthly = "월간"
    }
    
    enum ScreenType {
        case home
        case search
    }
    
    struct FilterState {
        let area: AreaCode?
        let dateType: DateRangeType
        let startDate: String
        let endDate: String
        let isReset: Bool
        
        init(area: AreaCode? = nil,
             dateType: DateRangeType = .daily,
             startDate: String = Date().yesterday.toKopisAPIFormatt,
             endDate: String = Date().yesterday.toKopisAPIFormatt,
             isReset: Bool = false) {
            self.area = area
            self.dateType = dateType
            self.startDate = startDate
            self.endDate = endDate
            self.isReset = isReset
        }
    }
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var screenType: ScreenType = .home
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    private let resetButton = ResetFilterButton()
    
    private lazy var areaButton: DropdownFilterButton = {
        let items = AreaCode.allCases.map { area in
            DropdownFilterButton.Item(title: area.displayName, value: area)
        }
        return DropdownFilterButton(items: items, title: "전국")
    }()
    
    private lazy var dateTypeButton: DropdownFilterButton = {
        let items = DateRangeType.allCases.map { type in
            DropdownFilterButton.Item(title: type.rawValue, value: type)
        }
        return DropdownFilterButton(items: items, title: "일간")
    }()
    
    private var dateSelectorButton: DatePickerFilterButton?
    
    // MARK: - State Management
    private let filterStateRelay = BehaviorRelay<FilterState>(value: FilterState())
    private let selectedAreaRelay = BehaviorRelay<AreaCode?>(value: nil)
    private let selectedDateTypeRelay = BehaviorRelay<DateRangeType>(value: .daily)
    private lazy var selectedDateRelay = BehaviorRelay<Date>(value: screenType == .search ? Date() : Date().yesterday)
    
    // MARK: - Public Configuration
    func configure(screenType: ScreenType) {
        self.screenType = screenType
        setupDateSelectorButton()
    }
    
    // MARK: - Private Setup
    private func setupDateSelectorButton() {
        // 기존 버튼이 있다면 제거
        if let existingButton = dateSelectorButton {
            existingButton.removeFromSuperview()
            contentStackView.removeArrangedSubview(existingButton)
        }
        
        // 새로운 버튼 생성
        let allowFuture = (screenType == .search)
        let initialDate = allowFuture ? Date() : Date().yesterday
        let button = DatePickerFilterButton(
            allowFuture: allowFuture,
            initialDate: initialDate
        )
        
        self.dateSelectorButton = button
        
        // 스택뷰에 추가 (마지막 위치)
        contentStackView.addArrangedSubview(button)
        
        button.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
    }
    
    // MARK: - Public Observables
    var filterState: Observable<FilterState> {
        return filterStateRelay.asObservable()
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        setupBindings()
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        [resetButton, areaButton, dateTypeButton].forEach {
            contentStackView.addArrangedSubview($0)
        }
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(44)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        // 각 버튼들의 최소 너비 설정 (intrinsicContentSize 활용)
        [resetButton, areaButton, dateTypeButton].forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(32)
            }
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // 초기화 버튼
        resetButton.selectedValue
            .skip(1)
            .subscribe(with: self) { owner, _ in
                owner.handleReset()
            }
            .disposed(by: disposeBag)
        
        // 지역 버튼
        areaButton.selectedValue
            .skip(1)
            .subscribe(with: self) { owner, value in
                if let area = value as? AreaCode {
                    owner.handleAreaSelection(area)
                }
            }
            .disposed(by: disposeBag)
        
        // 날짜 타입 버튼
        dateTypeButton.selectedValue
            .skip(1)
            .subscribe(with: self) { owner, value in
                if let dateType = value as? DateRangeType {
                    owner.handleDateTypeSelection(dateType)
                }
            }
            .disposed(by: disposeBag)
        
        // 날짜 선택 버튼
        dateSelectorButton?.selectedValue
            .skip(1)
            .subscribe(with: self) { owner, value in
                if let date = value as? Date {
                    owner.handleDateSelection(date)
                }
            }
            .disposed(by: disposeBag)
        
        // 상태 변경 감지
        bindStateChanges()
    }
    
    private func bindStateChanges() {
        selectedAreaRelay
            .subscribe(with: self) { owner, _ in
                owner.updateFilterState()
            }
            .disposed(by: disposeBag)
        
        selectedDateTypeRelay
            .subscribe(with: self) { owner, dateType in
                let currentDate = owner.selectedDateRelay.value
                owner.updateDateSelectorTitle(dateType: dateType, date: currentDate)
                owner.updateFilterState()
            }
            .disposed(by: disposeBag)
        
        selectedDateRelay
            .withLatestFrom(selectedDateTypeRelay) { ($0, $1) }
            .subscribe(with: self) { owner, data in
                let (date, dateType) = data
                owner.updateDateSelectorTitle(dateType: dateType, date: date)
                owner.updateFilterState()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action Handlers
    private func handleReset() {
        selectedAreaRelay.accept(nil)
        selectedDateTypeRelay.accept(.daily)
        selectedDateRelay.accept(Date().yesterday)
        
        // 버튼 타이틀 초기화
        areaButton.updateTitle("전국")
        dateTypeButton.updateTitle("일간")
        updateDateSelectorTitle(dateType: .daily, date: Date().yesterday)
        
        let resetState = FilterState(isReset: true)
        filterStateRelay.accept(resetState)
    }
    
    private func handleAreaSelection(_ area: AreaCode) {
        selectedAreaRelay.accept(area)
    }
    
    private func handleDateTypeSelection(_ dateType: DateRangeType) {
        selectedDateTypeRelay.accept(dateType)
    }
    
    private func handleDateSelection(_ date: Date) {
        selectedDateRelay.accept(date)
    }
    
    // MARK: - Helper Methods
    private func updateFilterState() {
        let area = selectedAreaRelay.value
        let dateType = selectedDateTypeRelay.value
        let selectedDate = selectedDateRelay.value
        
        let (startDate, endDate) = calculateDateRange(for: dateType, selectedDate: selectedDate)
        
        let state = FilterState(
            area: area,
            dateType: dateType,
            startDate: startDate,
            endDate: endDate,
            isReset: false
        )
        
        filterStateRelay.accept(state)
    }
    
    private func updateDateSelectorTitle(dateType: DateRangeType, date: Date) {
        let title = formatDateTitle(dateType, date)
        dateSelectorButton?.updateTitle(title)
    }
    
    private func calculateDateRange(for dateType: DateRangeType, selectedDate: Date) -> (String, String) {
        let calendar = Calendar.current
        
        switch dateType {
        case .daily:
            let dateString = selectedDate.toKopisAPIFormatt
            return (dateString, dateString)
            
        case .weekly:
            let weekday = calendar.component(.weekday, from: selectedDate)
            let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
            
            guard let mondayDate = calendar.date(byAdding: .day, value: -daysFromMonday, to: selectedDate),
                  let sundayDate = calendar.date(byAdding: .day, value: 6, to: mondayDate) else {
                let dateString = selectedDate.toKopisAPIFormatt
                return (dateString, dateString)
            }
            
            return (mondayDate.toKopisAPIFormatt, sundayDate.toKopisAPIFormatt)
            
        case .monthly:
            let year = calendar.component(.year, from: selectedDate)
            let month = calendar.component(.month, from: selectedDate)
            
            guard let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
                  let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDay) else {
                let dateString = selectedDate.toKopisAPIFormatt
                return (dateString, dateString)
            }
            
            let maxDay = calendar.date(byAdding: .day, value: 29, to: firstDay)
            let endDate = min(lastDayOfMonth, maxDay ?? lastDayOfMonth)
            
            return (firstDay.toKopisAPIFormatt, endDate.toKopisAPIFormatt)
        }
    }
    
    private func formatDateTitle(_ dateType: DateRangeType, _ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        switch dateType {
        case .daily:
            formatter.dateFormat = "yyyy.MM.dd(E)"
            return formatter.string(from: date)
            
        case .weekly:
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: date)
            let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
            
            guard let mondayDate = calendar.date(byAdding: .day, value: -daysFromMonday, to: date),
                  let sundayDate = calendar.date(byAdding: .day, value: 6, to: mondayDate) else {
                return "주간"
            }
            
            formatter.dateFormat = "yyyy.MM.dd"
            let startString = formatter.string(from: mondayDate)
            let endString = formatter.string(from: sundayDate)
            return "\(startString) ~ \(endString)"
            
        case .monthly:
            formatter.dateFormat = "yyyy.MM"
            return formatter.string(from: date)
        }
    }
}

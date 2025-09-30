//
//  FilterButtonContainer.swift
//  CurtainCall
//
//  Created by 서준일 on 9/28/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class FilterButtonContainer: BaseView {
    
    // MARK: - Types
    enum DateRangeType: String, CaseIterable {
        case daily = "일간"
        case weekly = "주간"
        case monthly = "월간"
    }
    
    enum ScreenType {
        case home       // 홈 화면 (과거만)
        case search     // 검색 화면 (미래 가능)
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
    private let disposeBag = DisposeBag()
    private let screenType: ScreenType
    
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    private lazy var resetButton: FilterButton = {
        let button = FilterButton(
            type: .reset,
            title: "",
            icon: UIImage(systemName: "arrow.trianglehead.clockwise.rotate.90")
        )
        return button
    }()
    
    private lazy var areaButton: FilterButton = {
        let items = AreaCode.allCases.map { area in
            FilterButton.DropdownItem(title: area.displayName, value: area)
        }
        let button = FilterButton(
            type: .dropdown(items: items),
            title: "전국"
        )
        return button
    }()
    
    private lazy var dateTypeButton: FilterButton = {
        let items = DateRangeType.allCases.map { type in
            FilterButton.DropdownItem(title: type.rawValue, value: type)
        }
        let button = FilterButton(
            type: .dropdown(items: items),
            title: "일간"
        )
        return button
    }()
    
    private lazy var dateSelectorButton: FilterButton = {
        let allowFuture = (screenType == .search)
        let button = FilterButton(
            type: .datePicker(allowFuture: allowFuture),
            title: formatDateTitle(.daily, Date().yesterday)
        )
        return button
    }()
    
    private lazy var spacerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - State Management
    private let filterStateRelay = BehaviorRelay<FilterState>(value: FilterState())
    private let selectedAreaRelay = BehaviorRelay<AreaCode?>(value: nil)
    private let selectedDateTypeRelay = BehaviorRelay<DateRangeType>(value: .daily)
    private let selectedDateRelay = BehaviorRelay<Date>(value: Date().yesterday)
    
    // MARK: - Public Observables
    var filterState: Observable<FilterState> {
        return filterStateRelay.asObservable()
    }
    
    // MARK: - Init
    init(screenType: ScreenType = .home) {
        self.screenType = screenType
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(stackView)
        addSubview(dateSelectorButton)
        
        [resetButton, areaButton, dateTypeButton, spacerView].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    override func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        dateSelectorButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().inset(4)
        }
        
        resetButton.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(50)
        }
        
        spacerView.setContentHuggingPriority(.init(1), for: .horizontal)
        spacerView.setContentCompressionResistancePriority(.init(1), for: .horizontal)
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .clear
        bindButtons()
        bindStateChanges()
    }
    
    // MARK: - Binding Methods
    private func bindButtons() {
        resetButton.selectedValue
            .compactMap { $0 as? String }
            .filter { $0 == "reset" }
            .subscribe(with: self) { owner, _ in
                owner.handleReset()
            }
            .disposed(by: disposeBag)
        
        areaButton.selectedValue
            .subscribe(with: self) { owner, selectedValue in
                if let areaCode = selectedValue as? AreaCode {
                    owner.handleAreaSelection(areaCode)
                }
            }
            .disposed(by: disposeBag)
        
        dateTypeButton.selectedValue
            .compactMap { $0 as? DateRangeType }
            .subscribe(with: self) { owner, selectedDateType in
                owner.handleDateTypeSelection(selectedDateType)
            }
            .disposed(by: disposeBag)
        
        dateSelectorButton.selectedValue
            .compactMap { $0 as? Date }
            .subscribe(with: self) { owner, selectedDate in
                owner.handleDateSelection(selectedDate)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindStateChanges() {
        selectedAreaRelay
            .subscribe(with: self) { owner, area in
                let title = area?.displayName ?? "전국"
                owner.areaButton.setTitle(title)
                owner.updateFilterState()
            }
            .disposed(by: disposeBag)
        
        selectedDateTypeRelay
            .subscribe(with: self) { owner, dateType in
                owner.dateTypeButton.setTitle(dateType.rawValue)
                
                let currentDate = owner.selectedDateRelay.value
                let newTitle = owner.formatDateTitle(dateType, currentDate)
                owner.dateSelectorButton.setTitle(newTitle)
                
                owner.updateFilterState()
            }
            .disposed(by: disposeBag)
        
        selectedDateRelay
            .withLatestFrom(selectedDateTypeRelay) { ($0, $1) }
            .subscribe(with: self) { owner, data in
                let (date, dateType) = data
                let title = owner.formatDateTitle(dateType, date)
                owner.dateSelectorButton.setTitle(title)
                owner.updateFilterState()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action Handlers
    private func handleReset() {
        selectedAreaRelay.accept(nil)
        selectedDateTypeRelay.accept(.daily)
        selectedDateRelay.accept(Date().yesterday)
        
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
    
    private func calculateDateRange(for dateType: DateRangeType, selectedDate: Date) -> (String, String) {
        let calendar = Calendar.current
        
        switch dateType {
        case .daily:
            let dateString = selectedDate.toKopisAPIFormatt
            return (dateString, dateString)
            
        case .weekly:
            // 해당 주의 월요일부터 일요일까지
            let weekday = calendar.component(.weekday, from: selectedDate)
            let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
            
            guard let mondayDate = calendar.date(byAdding: .day, value: -daysFromMonday, to: selectedDate),
                  let sundayDate = calendar.date(byAdding: .day, value: 6, to: mondayDate) else {
                let dateString = selectedDate.toKopisAPIFormatt
                return (dateString, dateString)
            }
            
            return (mondayDate.toKopisAPIFormatt, sundayDate.toKopisAPIFormatt)
            
        case .monthly:
            // 해당 월의 첫째 날부터 최대 30일까지 (31일 제한)
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
            return "\(startString) ~ \(endString)."
            
        case .monthly:
            formatter.dateFormat = "yyyy.MM"
            return formatter.string(from: date) + "."
        }
    }
}

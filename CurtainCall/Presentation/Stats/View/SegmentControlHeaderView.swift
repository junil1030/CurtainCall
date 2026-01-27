//
//  SegmentControlHeaderView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Foundation

final class SegmentControlHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    static let identifier = "SegmentControlHeaderView"
    private(set) var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: StatsPeriod.allCases.map { $0.rawValue })
        control.selectedSegmentIndex = 1
        control.backgroundColor = .white
        control.selectedSegmentTintColor = .ccPrimary
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        
        return control
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccBackground
        return view
    }()

    private let dateNavigationContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .ccPrimary
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .ccPrimary
        return button
    }()

    private let dateLabel: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.ccPrimaryText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        return button
    }()

    // MARK: - Observables
    private let periodSelectedSubject = PublishSubject<StatsPeriod>()
    private let previousPeriodTappedSubject = PublishSubject<Void>()
    private let nextPeriodTappedSubject = PublishSubject<Void>()
    private let dateLabelTappedSubject = PublishSubject<Void>()

    var periodSelected: Observable<StatsPeriod> {
        return periodSelectedSubject.asObservable()
    }

    var previousPeriodTapped: Observable<Void> {
        return previousPeriodTappedSubject.asObservable()
    }

    var nextPeriodTapped: Observable<Void> {
        return nextPeriodTappedSubject.asObservable()
    }

    var dateLabelTapped: Observable<Void> {
        return dateLabelTappedSubject.asObservable()
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupHierarchy()
        setupLayout()
        setupStyle()
        setupBind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        setupBind()
    }
    
    // MARK: - Setup
    private func setupHierarchy() {
        addSubview(containerView)
        containerView.addSubview(segmentControl)
        containerView.addSubview(dateNavigationContainer)

        dateNavigationContainer.addSubview(previousButton)
        dateNavigationContainer.addSubview(dateLabel)
        dateNavigationContainer.addSubview(nextButton)
    }

    private func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        segmentControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }

        dateNavigationContainer.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(36)
        }

        previousButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        dateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
    }
    
    private func setupStyle() {
        backgroundColor = .ccBackground
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }
    
    private func setupBind() {
        segmentControl.rx.selectedSegmentIndex
            .map { index -> StatsPeriod in
                return StatsPeriod.allCases[index]
            }
            .bind(to: periodSelectedSubject)
            .disposed(by: disposeBag)

        previousButton.rx.tap
            .bind(to: previousPeriodTappedSubject)
            .disposed(by: disposeBag)

        nextButton.rx.tap
            .bind(to: nextPeriodTappedSubject)
            .disposed(by: disposeBag)

        dateLabel.rx.tap
            .bind(to: dateLabelTappedSubject)
            .disposed(by: disposeBag)
    }

    // MARK: - Public Methods

    /// 현재 선택된 기간 설정
    func configure(selectedPeriod: StatsPeriod) {
        if let index = StatsPeriod.allCases.firstIndex(of: selectedPeriod) {
            segmentControl.selectedSegmentIndex = index
        }
    }

    /// 날짜 라벨 업데이트
    func configureDateLabel(for period: StatsPeriod, date: Date) {
        let text: String
        let isCurrentPeriod = isCurrentPeriod(for: period, date: date)

        switch period {
        case .weekly:
            let (start, end) = DateCalculator.dateRange(for: .weekly, from: date)
            text = "\(start.formatted("yyyy.MM.dd")) - \(end.formatted("yyyy.MM.dd"))"
        case .monthly:
            text = date.formatted("yyyy년 M월")
        case .yearly:
            text = date.formatted("yyyy년")
        }

        let displayText = isCurrentPeriod ? "\(text) (현재)" : text
        dateLabel.setTitle(displayText, for: .normal)

        // 다음 버튼 활성화 상태 업데이트
        nextButton.isEnabled = !isCurrentPeriod
        nextButton.alpha = isCurrentPeriod ? 0.3 : 1.0
    }

    /// 현재 기간인지 확인
    private func isCurrentPeriod(for period: StatsPeriod, date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        switch period {
        case .weekly:
            let (currentStart, currentEnd) = DateCalculator.dateRange(for: .weekly, from: now)
            let (selectedStart, _) = DateCalculator.dateRange(for: .weekly, from: date)
            return calendar.isDate(currentStart, inSameDayAs: selectedStart)
        case .monthly:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .yearly:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        }
    }
}

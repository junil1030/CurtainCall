//
//  StatsViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation
import RxSwift
import RxCocoa

final class StatsViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let useCase: FetchStatsUseCase
    
    // MARK: - Streams
    private let statsSectionsRelay = BehaviorRelay<[StatsSection: [StatsItem]]>(value: [:])
    private let selectedPeriodRelay = BehaviorRelay<StatsPeriod>(value: .monthly)
    private let selectedDateRelay = BehaviorRelay<Date>(value: Date())
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let showDatePickerRelay = PublishRelay<(StatsPeriod, Date)>()
    
    // MARK: - Input / Output
    struct Input {
        let periodChanged: Observable<StatsPeriod>
        let previousPeriodTapped: Observable<Void>
        let nextPeriodTapped: Observable<Void>
        let dateLabelTapped: Observable<Void>
        let dateSelected: Observable<Date>
    }

    struct Output {
        let statsSections: Driver<[StatsSection: [StatsItem]]>
        let selectedPeriod: Driver<StatsPeriod>
        let isLoading: Driver<Bool>
        let currentDateRange: Driver<(StatsPeriod, Date)>
        let showDatePicker: Driver<(StatsPeriod, Date)>
    }
    
    // MARK: - Init
    init(useCase: FetchStatsUseCase) {
        self.useCase = useCase
        super.init()

        loadStats(for: selectedPeriodRelay.value, date: selectedDateRelay.value)
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {

        // 기간 변경 시 현재 날짜로 리셋하고 통계 로드
        input.periodChanged
            .bind(with: self) { owner, period in
                owner.selectedPeriodRelay.accept(period)
                owner.selectedDateRelay.accept(Date())
                owner.loadStats(for: period, date: Date())
            }
            .disposed(by: disposeBag)

        // 이전 기간 버튼 탭
        input.previousPeriodTapped
            .withLatestFrom(Observable.combineLatest(
                selectedPeriodRelay.asObservable(),
                selectedDateRelay.asObservable()
            ))
            .bind(with: self) { owner, tuple in
                let (period, currentDate) = tuple
                let previousDate = owner.calculatePreviousDate(for: period, from: currentDate)
                owner.selectedDateRelay.accept(previousDate)
                owner.loadStats(for: period, date: previousDate)
            }
            .disposed(by: disposeBag)

        // 다음 기간 버튼 탭
        input.nextPeriodTapped
            .withLatestFrom(Observable.combineLatest(
                selectedPeriodRelay.asObservable(),
                selectedDateRelay.asObservable()
            ))
            .bind(with: self) { owner, tuple in
                let (period, currentDate) = tuple
                let nextDate = owner.calculateNextDate(for: period, from: currentDate)
                owner.selectedDateRelay.accept(nextDate)
                owner.loadStats(for: period, date: nextDate)
            }
            .disposed(by: disposeBag)

        // 날짜 라벨 탭 - 데이트 피커 표시
        input.dateLabelTapped
            .withLatestFrom(Observable.combineLatest(
                selectedPeriodRelay.asObservable(),
                selectedDateRelay.asObservable()
            ))
            .bind(to: showDatePickerRelay)
            .disposed(by: disposeBag)

        // 날짜 선택
        input.dateSelected
            .withLatestFrom(selectedPeriodRelay.asObservable()) { ($1, $0) }
            .bind(with: self) { owner, tuple in
                let (period, date) = tuple
                owner.selectedDateRelay.accept(date)
                owner.loadStats(for: period, date: date)
            }
            .disposed(by: disposeBag)

        // 현재 날짜 범위 스트림
        let currentDateRange = Observable.combineLatest(
            selectedPeriodRelay.asObservable(),
            selectedDateRelay.asObservable()
        )
        .asDriver(onErrorJustReturn: (.monthly, Date()))

        return Output(
            statsSections: statsSectionsRelay.asDriver(),
            selectedPeriod: selectedPeriodRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            currentDateRange: currentDateRange,
            showDatePicker: showDatePickerRelay.asDriver(onErrorJustReturn: (.monthly, Date()))
        )
    }
    
    // MARK: - Private Methods

    private func loadStats(for period: StatsPeriod, date: Date) {
        isLoadingRelay.accept(true)

        // UseCase 실행 (커스텀 날짜 전달)
        let input = FetchStatsUseCase.Input(period: period, date: date)
        let statsData = useCase.execute(input)

        // Domain → Presentation 변환
        let sections = StatsItemMapper.mapToItems(from: statsData)

        statsSectionsRelay.accept(sections)
        isLoadingRelay.accept(false)
    }

    private func calculatePreviousDate(for period: StatsPeriod, from date: Date) -> Date {
        let calendar = Calendar.current
        switch period {
        case .weekly:
            return calendar.date(byAdding: .day, value: -7, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: -1, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: -1, to: date) ?? date
        }
    }

    private func calculateNextDate(for period: StatsPeriod, from date: Date) -> Date {
        let calendar = Calendar.current
        let nextDate: Date
        switch period {
        case .weekly:
            nextDate = calendar.date(byAdding: .day, value: 7, to: date) ?? date
        case .monthly:
            nextDate = calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .yearly:
            nextDate = calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
        // Prevent future dates
        return nextDate > Date() ? date : nextDate
    }
}

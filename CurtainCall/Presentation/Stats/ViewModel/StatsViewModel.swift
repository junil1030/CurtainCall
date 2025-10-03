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
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Input / Output
    struct Input {
        let periodChanged: Observable<StatsPeriod>
    }
    
    struct Output {
        let statsSections: Driver<[StatsSection: [StatsItem]]>
        let selectedPeriod: Driver<StatsPeriod>
        let isLoading: Driver<Bool>
    }
    
    // MARK: - Init
    init(useCase: FetchStatsUseCase) {
        self.useCase = useCase
        super.init()
        
        loadStats(for: selectedPeriodRelay.value)
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        
        input.periodChanged
            .bind(with: self) { owner, period in
                owner.selectedPeriodRelay.accept(period)
                owner.loadStats(for: period)
            }
            .disposed(by: disposeBag)
        
        return Output(
            statsSections: statsSectionsRelay.asDriver(),
            selectedPeriod: selectedPeriodRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver()
        )
    }
    
    // MARK: - Private Methods
    
    private func loadStats(for period: StatsPeriod) {
        isLoadingRelay.accept(true)
        
        // UseCase 실행
        let statsData = useCase.execute(period)
        
        // Domain → Presentation 변환
        let sections = StatsItemMapper.mapToItems(from: statsData)
        
        statsSectionsRelay.accept(sections)
        isLoadingRelay.accept(false)
    }
}

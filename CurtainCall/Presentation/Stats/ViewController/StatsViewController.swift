//
//  StatsViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import UIKit
import RxSwift
import RxCocoa

final class StatsViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: StatsViewModel
    private let statsView = StatsView()
    private let disposeBag = DisposeBag()
    private let dateSelectionRelay = PublishRelay<Date>()
    
    // MARK: - Init
    init(viewModel: StatsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func loadView() {
        view = statsView
    }
    
    // MARK: - Override Methods
    override func setupStyle() {
        super.setupStyle()
        navigationItem.title = "통계"
    }
    
    override func setupBind() {
        super.setupBind()

        let input = StatsViewModel.Input(
            periodChanged: statsView.periodChanged,
            previousPeriodTapped: statsView.previousPeriodTapped,
            nextPeriodTapped: statsView.nextPeriodTapped,
            dateLabelTapped: statsView.dateLabelTapped,
            dateSelected: dateSelectionRelay.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.statsSections
            .drive(with: self) { owner, sections in
                owner.statsView.updateStats(sections: sections)
            }
            .disposed(by: disposeBag)

        output.isLoading
            .drive(with: self) { owner, isLoading in
                // 인디케이터
                print("로딩 상태: \(isLoading)")
            }
            .disposed(by: disposeBag)

        output.selectedPeriod
            .drive(with: self) { owner, period in
                // 디버깅
                print("현재 선택된 기간: \(period.rawValue)")
            }
            .disposed(by: disposeBag)

        // 현재 날짜 범위 업데이트
        output.currentDateRange
            .drive(with: self) { owner, tuple in
                let (period, date) = tuple
                owner.statsView.updateDateLabel(for: period, date: date)
            }
            .disposed(by: disposeBag)

        // 날짜 피커 표시
        output.showDatePicker
            .drive(with: self) { owner, tuple in
                let (period, date) = tuple
                owner.presentDatePicker(for: period, currentDate: date)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Private Methods

    private func presentDatePicker(for period: StatsPeriod, currentDate: Date) {
        guard presentedViewController == nil else { return }

        let bottomSheet = FilterBottomSheetViewController(
            contentType: .datePicker(allowFuture: false, initialDate: currentDate)
        )

        bottomSheet.selection
            .take(1)
            .compactMap { $0 as? Date }
            .subscribe(with: self) { owner, date in
                owner.dateSelectionRelay.accept(date)
            }
            .disposed(by: disposeBag)

        // ⚠️ IMPORTANT: animated: false로 해야 함!
        // FilterBottomSheet는 자체 애니메이션(showBottomSheet)을 가지고 있음
        // animated: true로 하면 iOS 기본 애니메이션 + custom 애니메이션이 중첩되어 느려짐
        present(bottomSheet, animated: false)
    }
}

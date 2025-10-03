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
            periodChanged: statsView.periodChanged
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
    }
}

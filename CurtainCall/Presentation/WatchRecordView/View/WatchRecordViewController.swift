//
//  WatchRecordViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import RxCocoa

final class WatchRecordViewController: BaseViewController {
    
    // MARK: - Properties
    private let watchRecordView = WatchRecordView()
    private let viewModel: WatchRecordViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(viewModel: WatchRecordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        view = watchRecordView
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.title = "관람 기록 추가"
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = WatchRecordViewModel.Input(
            viewingDateSelected: watchRecordView.dateButtonTapped,
            viewingTimeSelected: watchRecordView.timeButtonTapped,
            companionSelected: watchRecordView.companionSelected,
            seatTextChanged: watchRecordView.seatTextChanged,
            ratingChanged: watchRecordView.ratingChanged,
            reviewTextChanged: watchRecordView.reviewTextChanged,
            saveButtonTapped: watchRecordView.saveButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        output.performanceDetail
            .drive(with: self) { owner, detail in
                owner.watchRecordView.configure(with: detail)
            }
            .disposed(by: disposeBag)
        
        // 저장 성공
        output.saveSuccess
            .emit(with: self) { owner, _ in
                owner.showSuccessAlert()
            }
            .disposed(by: disposeBag)
        
        // 에러 처리
        output.error
            .emit(with: self) { owner, error in
                owner.showErrorAlert(error: error)
            }
            .disposed(by: disposeBag)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "저장 완료",
            message: "관람 기록이 저장되었습니다.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}

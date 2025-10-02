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
    
    // MARK: - Subjects
    private let viewingDateSelectedSubject = PublishSubject<Date>()
    private let viewingTimeSelectedSubject = PublishSubject<Date>()
    private let companionSelectedSubject = PublishSubject<WatchRecordViewModel.CompanionType>()
    
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
            viewingDateSelected: viewingDateSelectedSubject.asObservable(),
            viewingTimeSelected: viewingTimeSelectedSubject.asObservable(),
            companionSelected: companionSelectedSubject.asObservable(),
            seatTextChanged: watchRecordView.seatTextChanged,
            saveButtonTapped: Observable.never() // TODO: 저장 버튼 추가 시 연결
        )
        
        let output = viewModel.transform(input: input)
        
        // 공연 상세 정보 바인딩
        output.performanceDetail
            .drive(with: self) { owner, detail in
                owner.watchRecordView.configure(with: detail)
            }
            .disposed(by: disposeBag)
        
        // 날짜 버튼 탭 처리
        watchRecordView.dateButtonTapped
            .subscribe(with: self) { owner, _ in
                owner.showDatePicker()
            }
            .disposed(by: disposeBag)
        
        // 시간 버튼 탭 처리
        watchRecordView.timeButtonTapped
            .subscribe(with: self) { owner, _ in
                owner.showTimePicker()
            }
            .disposed(by: disposeBag)
        
        // 함께한 사람 선택 처리
        watchRecordView.companionSelected
            .compactMap { WatchRecordViewModel.CompanionType(rawValue: $0) }
            .bind(to: companionSelectedSubject)
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
    
    // MARK: - Private Methods
    private func showDatePicker() {
        let datePickerVC = CustomDatePickerView(initialDate: Date(), allowFuture: false)
        
        datePickerVC.selectedDate
            .take(1)
            .bind(to: viewingDateSelectedSubject)
            .disposed(by: disposeBag)
        
        if let sheet = datePickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(datePickerVC, animated: true)
    }
    
    private func showTimePicker() {
        let timePickerVC = CustomTimePickerView(initialDate: Date())
        
        timePickerVC.selectedTime
            .take(1)
            .bind(to: viewingTimeSelectedSubject)
            .disposed(by: disposeBag)
        
        if let sheet = timePickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(timePickerVC, animated: true)
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

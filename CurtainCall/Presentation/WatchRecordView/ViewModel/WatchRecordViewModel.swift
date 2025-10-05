//
//  WatchRecordViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import Foundation
import RxSwift
import RxCocoa

final class WatchRecordViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let performanceDetail: PerformanceDetail
    private var existingRecord: ViewingRecord?
    
    // MARK: - UseCase
    private let addViewingRecordUseCase: AddViewingRecordUseCase
    private let getViewingRecordUseCase: GetViewingRecordByPerformanceUseCase
    private let updateViewingRecordUseCase: UpdateViewingRecordUseCase
    
    // MARK: - Streams
    private let viewingDateRelay = BehaviorRelay<Date>(value: Date())
    private let viewingTimeRelay = BehaviorRelay<Date>(value: Date())
    private let companionRelay = BehaviorRelay<String>(value: "")
    private let seatRelay = BehaviorRelay<String>(value: "")
    private let ratingRelay = BehaviorRelay<Int>(value: 0)
    private let reviewRelay = BehaviorRelay<String>(value: "")
    private let isEditModeRelay = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Types
    enum CompanionType: String, CaseIterable {
        case alone = "혼자"
        case friend = "친구"
        case family = "가족"
        case lover = "연인"
        case other = "기타"
    }
    
    // MARK: - Input / Output
    struct Input {
        let viewingDateSelected: Observable<Date>
        let viewingTimeSelected: Observable<Date>
        let companionSelected: Observable<String>
        let seatTextChanged: Observable<String>
        let ratingChanged: Observable<Int>
        let reviewTextChanged: Observable<String>
        let saveButtonTapped: Observable<Void>
    }
    
    struct Output {
        let performanceDetail: Driver<PerformanceDetail>
        let initialData: Driver<ViewingRecordData?>
        let isFormValid: Driver<Bool>
        let isEditMode: Driver<Bool>
        let saveSuccess: Signal<Void>
        let error: Signal<Error>
    }
    
    // MARK: - Init
    init(
        performanceDetail: PerformanceDetail,
        addViewingRecordUseCase: AddViewingRecordUseCase,
        getViewingRecordUseCase: GetViewingRecordByPerformanceUseCase,
        updateViewingRecordUseCase: UpdateViewingRecordUseCase
    ) {
        self.performanceDetail = performanceDetail
        self.addViewingRecordUseCase = addViewingRecordUseCase
        self.getViewingRecordUseCase = getViewingRecordUseCase
        self.updateViewingRecordUseCase = updateViewingRecordUseCase
        super.init()
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        let saveSuccessRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<Error>()
        let initialDataRelay = BehaviorRelay<ViewingRecordData?>(value: nil)
        
        // 입력 바인딩
        input.viewingDateSelected
            .bind(to: viewingDateRelay)
            .disposed(by: disposeBag)
        
        input.viewingTimeSelected
            .bind(to: viewingTimeRelay)
            .disposed(by: disposeBag)
        
        input.companionSelected
            .bind(to: companionRelay)
            .disposed(by: disposeBag)
        
        input.seatTextChanged
            .bind(to: seatRelay)
            .disposed(by: disposeBag)
        
        input.ratingChanged
            .bind(to: ratingRelay)
            .disposed(by: disposeBag)
        
        input.reviewTextChanged
            .bind(to: reviewRelay)
            .disposed(by: disposeBag)
        
        // 폼 유효성 검사 (모든 필수값이 채워졌는지)
        let isFormValid = Observable.combineLatest(
            companionRelay,
            seatRelay,
            ratingRelay,
            reviewRelay
        )
        .map { companion, seat, rating, review in
            return !companion.isEmpty &&
                   !seat.isEmpty &&
                   rating > 0 &&
                   !review.isEmpty
        }
        .asDriver(onErrorJustReturn: false)
        
        // 저장 버튼 탭 처리
        input.saveButtonTapped
            .withLatestFrom(Observable.combineLatest(
                viewingDateRelay,
                viewingTimeRelay,
                companionRelay,
                seatRelay,
                ratingRelay,
                reviewRelay
            ))
            .subscribe(with: self) { owner, data in
                let (date, time, companion, seat, rating, review) = data
                
                if let existingRecord = owner.existingRecord {
                    // 수정 모드
                    let updateInput = ViewingRecordUpdateInput(
                        recordId: existingRecord.id,
                        viewingDate: date,
                        viewingTime: time,
                        companion: companion,
                        seat: seat,
                        rating: rating,
                        review: review
                    )
                    
                    let result = owner.updateViewingRecordUseCase.execute(updateInput)
                    
                    switch result {
                    case .success:
                        saveSuccessRelay.accept(())
                    case .failure(let error):
                        errorRelay.accept(error)
                    }
                } else {
                    // 생성 모드
                    let addInput = ViewingRecordInput(
                        performanceDetail: owner.performanceDetail,
                        viewingDate: date,
                        viewingTime: time,
                        companion: companion,
                        seat: seat,
                        rating: rating,
                        review: review
                    )
                    
                    let result = owner.addViewingRecordUseCase.execute(addInput)
                    
                    switch result {
                    case .success:
                        saveSuccessRelay.accept(())
                    case .failure(let error):
                        errorRelay.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // 기존 데이터 로드 후 initialData 설정
        loadExistingRecord(initialDataRelay: initialDataRelay)
        
        return Output(
            performanceDetail: .just(performanceDetail),
            initialData: initialDataRelay.asDriver(),
            isFormValid: isFormValid,
            isEditMode: isEditModeRelay.asDriver(),
            saveSuccess: saveSuccessRelay.asSignal(),
            error: errorRelay.asSignal()
        )
    }
    
    // MARK: - Private Methods
    private func loadExistingRecord(initialDataRelay: BehaviorRelay<ViewingRecordData?>) {
        // 기존 기록 조회
        existingRecord = getViewingRecordUseCase.execute(performanceDetail.id)
        
        print(performanceDetail.id)
        
        guard let record = existingRecord else {
            // 기록이 없으면 생성 모드
            isEditModeRelay.accept(false)
            initialDataRelay.accept(nil)
            return
        }
        
        // 기록이 있으면 수정 모드로 설정
        isEditModeRelay.accept(true)
        
        print("모드: \(isEditModeRelay.value ? "수정" : "생성")")
        
        // ViewingRecord를 ViewingRecordData로 변환
        let recordData = ViewingRecordToDataMapper.map(from: record)
        
        // 기존 데이터로 Relay 초기화 (폼 유효성 검사용)
        viewingDateRelay.accept(recordData.viewingDate)
        viewingTimeRelay.accept(recordData.viewingTime)
        companionRelay.accept(recordData.companion)
        seatRelay.accept(recordData.seat)
        ratingRelay.accept(recordData.rating)
        reviewRelay.accept(recordData.review)
        
        // View에 전달할 초기 데이터 설정
        initialDataRelay.accept(recordData)
    }
}

//
//  WriteRecordViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import Foundation
import RxSwift
import RxCocoa

final class WriteRecordViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let mode: WriteRecordMode
    private var performanceDetail: PerformanceDetail?
    private var existingRecordId: String?
    
    // MARK: - UseCase
    private let addViewingRecordUseCase: AddViewingRecordUseCase
    private let getViewingRecordByIdUseCase: GetViewingRecordByIdUseCase
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
        mode: WriteRecordMode,
        addViewingRecordUseCase: AddViewingRecordUseCase,
        getViewingRecordByIdUseCase: GetViewingRecordByIdUseCase,
        updateViewingRecordUseCase: UpdateViewingRecordUseCase
    ) {
        self.mode = mode
        self.addViewingRecordUseCase = addViewingRecordUseCase
        self.getViewingRecordByIdUseCase = getViewingRecordByIdUseCase
        self.updateViewingRecordUseCase = updateViewingRecordUseCase
        super.init()
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        let saveSuccessRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<Error>()
        let initialDataRelay = BehaviorRelay<ViewingRecordData?>(value: nil)
        let performanceDetailRelay = BehaviorRelay<PerformanceDetail?>(value: nil)
        
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
            let result = !companion.isEmpty &&
            rating > 0 &&
            !review.isEmpty
            return result
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
                
                switch owner.mode {
                case .create:
                    // 생성 모드
                    guard let detail = owner.performanceDetail else {
                        errorRelay.accept(WriteRecordError.missingPerformanceDetail)
                        return
                    }
                    
                    let addInput = ViewingRecordInput(
                        performanceDetail: detail,
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
                    
                case .edit:
                    // 수정 모드
                    guard let recordId = owner.existingRecordId else {
                        errorRelay.accept(WriteRecordError.missingRecordId)
                        return
                    }
                    
                    let updateInput = ViewingRecordUpdateInput(
                        recordId: recordId,
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
                }
            }
            .disposed(by: disposeBag)
        
        loadInitialData(
            performanceDetailRelay: performanceDetailRelay,
            initialDataRelay: initialDataRelay
        )
        
        return Output(
            performanceDetail: performanceDetailRelay.compactMap { $0 }.asDriver(onErrorDriveWith: .empty()),
            initialData: initialDataRelay.asDriver(),
            isFormValid: isFormValid,
            isEditMode: isEditModeRelay.asDriver(),
            saveSuccess: saveSuccessRelay.asSignal(),
            error: errorRelay.asSignal()
        )
    }
    
    // MARK: - Private Methods
    private func loadInitialData(
        performanceDetailRelay: BehaviorRelay<PerformanceDetail?>,
        initialDataRelay: BehaviorRelay<ViewingRecordData?>
    ) {
        switch mode {
        case .create(let detail):
            // 신규 생성 모드
            performanceDetail = detail
            performanceDetailRelay.accept(detail)
            isEditModeRelay.accept(false)
            initialDataRelay.accept(nil)
            
        case .edit(let recordId):
            // 수정 모드
            existingRecordId = recordId
            
            // recordId로 기존 기록 조회
            guard let recordDTO = getViewingRecordByIdUseCase.execute(recordId) else {
                // 기록을 찾을 수 없으면 에러 처리
                isEditModeRelay.accept(false)
                initialDataRelay.accept(nil)
                return
            }
            
            let castAry = recordDTO.cast.components(separatedBy: ",")
            
            // PerformanceDetail 재구성 (ViewingRecordDTO에서 추출)
            let detail = PerformanceDetail(
                id: recordDTO.id,
                title: recordDTO.title,
                startDate: nil,
                endDate: nil,
                area: recordDTO.area,
                location: recordDTO.location,
                genre: recordDTO.genre,
                posterURL: recordDTO.posterURL,
                detailPosterURL: nil,
                cast: castAry,
                bookingSites: nil,
                runtime: nil,
                ageRating: nil,
                ticketPrice: nil,
                producer: nil,
                planning: nil,
                host: nil,
                management: nil
            )
            
            performanceDetail = detail
            performanceDetailRelay.accept(detail)
            isEditModeRelay.accept(true)
            
            // ViewingRecordDTO를 ViewingRecordData로 변환
            let recordData = ViewingRecordDTOToDataMapper.map(from: recordDTO)
            
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
}

enum WriteRecordError: LocalizedError {
    case missingPerformanceDetail
    case missingRecordId
    
    var errorDescription: String? {
        switch self {
        case .missingPerformanceDetail:
            return "공연 정보를 불러올 수 없습니다."
        case .missingRecordId:
            return "기록 ID를 찾을 수 없습니다."
        }
    }
}

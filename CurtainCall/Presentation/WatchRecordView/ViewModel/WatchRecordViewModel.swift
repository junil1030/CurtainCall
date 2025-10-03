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
    
    // MARK: - Streams
    private let viewingDateRelay = BehaviorRelay<Date>(value: Date())
    private let viewingTimeRelay = BehaviorRelay<Date>(value: Date())
    private let companionRelay = PublishRelay<String>()
    private let seatRelay = PublishRelay<String>()
    private let ratingRelay = PublishRelay<Int>()
    private let reviewRelay = PublishRelay<String>()
    
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
        let saveSuccess: Signal<Void>
        let error: Signal<Error>
    }
    
    // MARK: - Init
    init(performanceDetail: PerformanceDetail) {
        self.performanceDetail = performanceDetail
        super.init()
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        let saveSuccessRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<Error>()
        
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
                
                print(data)
//                // 날짜와 시간 결합
//                let calendar = Calendar.current
//                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
//                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
//                
//                var combinedComponents = DateComponents()
//                combinedComponents.year = dateComponents.year
//                combinedComponents.month = dateComponents.month
//                combinedComponents.day = dateComponents.day
//                combinedComponents.hour = timeComponents.hour
//                combinedComponents.minute = timeComponents.minute
//                
//                guard let viewingDateTime = calendar.date(from: combinedComponents) else {
//                    errorRelay.accept(NSError(domain: "WatchRecordViewModel", code: -1, userInfo: [
//                        NSLocalizedDescriptionKey: "날짜 형식이 올바르지 않습니다."
//                    ]))
//                    return
//                }
//                
//                // ViewingRecord 생성 및 저장
//                let record = ViewingRecord(from: owner.performanceDetail, viewingDate: viewingDateTime)
//                record.seat = seat
//                
//                // TODO: Repository를 통해 저장
//                do {
//                    let repository = ViewingRecordRepository()
//                    try repository.addRecord(record)
//                    saveSuccessRelay.accept(())
//                } catch {
//                    errorRelay.accept(error)
//                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            performanceDetail: .just(performanceDetail),
            saveSuccess: saveSuccessRelay.asSignal(),
            error: errorRelay.asSignal()
        )
    }
}

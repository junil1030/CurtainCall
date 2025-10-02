//
//  DetailViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import Foundation
import RxSwift
import RxCocoa

final class DetailViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let performanceID: String
    private let disposeBag = DisposeBag()
    private var performanceDetail: PerformanceDetail?
    
    // MARK: - Streams
    private let performanceDetailRelay = BehaviorRelay<PerformanceDetail?>(value: nil)
    private let isFavoriteRelay = BehaviorRelay<Bool>(value: false)
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let openSafariRelay = PublishRelay<URL>()
    private let pushRecordRelay = PublishRelay<PerformanceDetail>()
    private let errorRelay = PublishRelay<NetworkError>()
    
    // MARK: - Input / Output
    struct Input {
        let favoriteButtonTapped: Observable<Void>
        let recordButtonTapped: Observable<Void>
        let bookingSiteTapped: Observable<String>
    }
    
    struct Output {
        let performanceDetail: Driver<PerformanceDetail>
        let isFavorite: Driver<Bool>
        let isLoading: Driver<Bool>
        let openSafari: Signal<URL>
        let pushRecord: Signal<PerformanceDetail>
        let error: Signal<NetworkError>
    }
    
    // MARK: - Init
    init(performanceID: String) {
        self.performanceID = performanceID
        super.init()
        
        loadPerformanceDetail()
        checkFavoriteStatus()
    }
    
    func transform(input: Input) -> Output {
        
        // 찜하기 버튼 탭
        input.favoriteButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.toggleFavorite()
            })
            .disposed(by: disposeBag)
        
        // 기록하기 버튼 탭
        input.recordButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                guard let detail = owner.performanceDetail else { return }
                owner.pushRecordRelay.accept(detail)
            })
            .disposed(by: disposeBag)
        
        // 예매 사이트 버튼 탭
        input.bookingSiteTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, urlString in
                owner.openBookingSite(urlString: urlString)
            })
            .disposed(by: disposeBag)
        
        return Output(
            performanceDetail: performanceDetailRelay
                .compactMap { $0 }
                .asDriver(onErrorDriveWith: .empty()),
            isFavorite: isFavoriteRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            openSafari: openSafariRelay.asSignal(),
            pushRecord: pushRecordRelay.asSignal(),
            error: errorRelay.asSignal()
        )
    }
    
    // MARK: - Private Methods
    private func loadPerformanceDetail() {
        isLoadingRelay.accept(true)
        
        CustomObservable.request(.detailPerformance(performanceID: performanceID),responseType: PerformanceDetailResponseDTO.self)
        .subscribe(with: self) { owner, response in
            owner.isLoadingRelay.accept(false)
            
            let detailDTO = response.dbs.db
            owner.performanceDetail = PerformanceDetailMapper.map(from: detailDTO)
            owner.performanceDetailRelay.accept(owner.performanceDetail)
            
        } onFailure: { owner, error in
            owner.isLoadingRelay.accept(false)
            
            if let networkError = error as? NetworkError {
                owner.errorRelay.accept(networkError)
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func checkFavoriteStatus() {
        // TODO: Realm에서 찜 상태 확인
        print("찜 상태 확인: \(performanceID)")
        isFavoriteRelay.accept(false)
    }
    
    private func toggleFavorite() {
        let currentStatus = isFavoriteRelay.value
        let newStatus = !currentStatus
        
        print("찜하기 토글: \(performanceID), 새 상태: \(newStatus)")
        
        // TODO: Realm에 저장/삭제
        isFavoriteRelay.accept(newStatus)
    }
    
    private func openBookingSite(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("유효하지 않은 URL: \(urlString)")
            return
        }
        
        print("예매 사이트 이동: \(urlString)")
        openSafariRelay.accept(url)
    }

}

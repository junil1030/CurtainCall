//
//  HomeViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UseCases
    private let getUserProfileUseCase: GetUserProfileUseCase
    
    // MARK: - Input / Output
    struct Input {
        let viewWillAppear: Observable<Void>
        let selectedCard: Observable<CardItem>
        let selectedCategory: Observable<CategoryCode?>
        let filterState: Observable<FilterButtonCell.FilterState>
        let searchButtonTapped: Observable<Void>
        let headerFavoriteButtonTapped: Observable<Void>
    }
    
    struct Output {
        let userProfile: Driver<UserProfile?>
        let cardItems: Driver<[CardItem]>
        let scrollToFirst: Signal<Void>
        let isLoading: Driver<Bool>
        let error: Signal<NetworkError>
        let navigateToSearch: Signal<Void>
        let navigateToFavorite: Signal<Void>
    }
    
    // MARK: - Stream
    private let userProfileRelay = BehaviorRelay<UserProfile?>(value: nil)
    private let boxOfficeListRelay = BehaviorRelay<[BoxOffice]>(value: [])
    private let cardItemsRelay = BehaviorRelay<[CardItem]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<NetworkError>()
    private let scrollToFirstRelay = PublishRelay<Void>()

    // MARK: - State
    private var hasLoadedInitialData = false
    
    // MARK: - Init
    init(getUserProfileUseCase: GetUserProfileUseCase) {
        self.getUserProfileUseCase = getUserProfileUseCase
        super.init()
    }
    
    func transform(input: Input) -> Output {
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                // 초기 데이터는 최초 1회만 로드
                if !owner.hasLoadedInitialData {
                    owner.loadInitialData()
                    owner.hasLoadedInitialData = true
                }
                // 사용자 프로필은 매번 업데이트
                owner.loadUserProfile()
            }
            .disposed(by: disposeBag)
        
        // 카테고리 변경 시 검색
        let categoryChanged = input.selectedCategory
            .distinctUntilChanged()
            .skip(1) // 초기값 스킵
        
        // 필터 상태 변경 시 검색
        let filterChanged = input.filterState
            .distinctUntilChanged { prev, curr in
                return prev.area?.rawValue == curr.area?.rawValue &&
                       prev.dateType == curr.dateType &&
                       prev.startDate == curr.startDate &&
                       prev.endDate == curr.endDate &&
                       prev.isReset == curr.isReset
            }
            .skip(1) // 초기값 스킵
        
        // 카테고리와 필터 결합
        let searchTrigger = Observable.merge(
            categoryChanged.withLatestFrom(input.filterState) { (category: $0, filter: $1) },
            filterChanged.withLatestFrom(input.selectedCategory) { (category: $1, filter: $0) }
        )
        
        searchTrigger
            .withUnretained(self)
            .filter { (owner, _) in
                return !owner.isLoadingRelay.value
            }
            .bind { owner, data in
                let (category, filterState) = data
                owner.performSearch(category: category, filterState: filterState)
            }
            .disposed(by: disposeBag)
        
        // 검색 버튼 탭 처리
        let navigateToSearch = input.searchButtonTapped
            .asSignal(onErrorSignalWith: .empty())
        
        // 헤더 찜 버튼 탭 처리
        let navigateToFavorite = input.headerFavoriteButtonTapped
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            userProfile: userProfileRelay.asDriver(),
            cardItems: cardItemsRelay.asDriver(),
            scrollToFirst: scrollToFirstRelay.asSignal(),
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asSignal(),
            navigateToSearch: navigateToSearch,
            navigateToFavorite: navigateToFavorite
        )
    }
    
    // MARK: - Private Methods
    
    private func loadUserProfile() {
        let profile = getUserProfileUseCase.execute(())
        userProfileRelay.accept(profile)
    }
    
    private func loadInitialData() {
        let today = Date()
        let yesterday = today.yesterday
        
        let startDate = yesterday.toKopisAPIFormatt
        let endDate = yesterday.toKopisAPIFormatt
        
        loadBoxOffice(startDate: startDate, endDate: endDate, category: .play, area: nil)
    }
    
    private func performSearch(category: CategoryCode?, filterState: FilterButtonCell.FilterState) {
        // 초기화 상태인 경우 기본값으로 검색
        if filterState.isReset {
            let yesterday = Date().yesterday
            let dateString = yesterday.toKopisAPIFormatt
            loadBoxOffice(startDate: dateString, endDate: dateString, category: category, area: nil)
            return
        }
        
        // 일반 검색
        loadBoxOffice(
            startDate: filterState.startDate,
            endDate: filterState.endDate,
            category: category,
            area: filterState.area
        )
    }
    
    private func loadBoxOffice(startDate: String, endDate: String, category: CategoryCode?, area: AreaCode?) {
        isLoadingRelay.accept(true)
        
        CustomObservable.request(.boxOffice(startDate: startDate, endDate: endDate, category: category, area: area), responseType: BoxOfficeResponseDTO.self)
            .subscribe(with: self) { owner, response in
                owner.isLoadingRelay.accept(false)
                let boxOffices = BoxOfficeMapper.map(from: response.boxofs.boxof)
                owner.boxOfficeListRelay.accept(boxOffices)
                
                let cardItems = owner.convertToCardItems(from: boxOffices)
                owner.cardItemsRelay.accept(cardItems)
                
                if !boxOffices.isEmpty { owner.scrollToFirstRelay.accept(()) }
            } onFailure: { owner, error in
                owner.isLoadingRelay.accept(false)
                if let networkError = error as? NetworkError {
                    owner.errorRelay.accept(networkError)
                }
                owner.boxOfficeListRelay.accept([])
                owner.cardItemsRelay.accept([])
            }
            .disposed(by: disposeBag)
    }
    
    private func convertToCardItems(from boxOffices: [BoxOffice]) -> [CardItem] {
        return boxOffices.map { boxOffice in
            return CardItem(
                id: boxOffice.performanceID,
                imageURL: boxOffice.posterURL,
                title: boxOffice.title,
                subtitle: boxOffice.location,
                period: boxOffice.performancePeriod,
                badge: boxOffice.rank
            )
        }
    }
}

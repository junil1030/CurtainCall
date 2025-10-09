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
    private let networkManager = NetworkManager.shared
    private let disposeBag = DisposeBag()
    
    // MARK: - UseCases
    private let getUserProfileUseCase: GetUserProfileUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let checkMultipleFavoriteStatusUseCase: CheckMultipleFavoriteStatusUseCase
    
    // MARK: - Input / Output
    struct Input {
        let viewWillAppear: Observable<Void>
        let selectedCard: Observable<CardItem>
        let selectedCategory: Observable<CategoryCode?>
        let filterState: Observable<FilterButtonContainer.FilterState>
        let favoriteButtonTapped: Observable<String>
        let bannerTapped: Observable<Void>
    }
    
    struct Output {
        let userProfile: Driver<UserProfile?>
        let cardItems: Driver<[CardItem]>
        let scrollToFirst: Signal<Void>
        let isLoading: Driver<Bool>
        let favoriteStatusChanged: Signal<(String, Bool)>
        let navigateToProfileEdit: Signal<Void>
    }
    
    // MARK: - Stream
    private let userProfileRelay = BehaviorRelay<UserProfile?>(value: nil)
    private let boxOfficeListRelay = BehaviorRelay<[BoxOffice]>(value: [])
    private let cardItemsRelay = BehaviorRelay<[CardItem]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<NetworkError>()
    private let scrollToFirstRelay = PublishRelay<Void>()
    private let favoriteStatusChangedRelay = PublishRelay<(String, Bool)>()
    
    // MARK: - Init
    init(
        getUserProfileUseCase: GetUserProfileUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        checkMultipleFavoriteStatusUseCase: CheckMultipleFavoriteStatusUseCase
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.checkMultipleFavoriteStatusUseCase = checkMultipleFavoriteStatusUseCase
        super.init()
        
        loadInitialData()
        loadUserProfile()
    }
    
    func transform(input: Input) -> Output {
        
        // viewWillAppear 시 프로필 로드 및 찜 상태 동기화
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                owner.loadUserProfile()
                owner.syncFavoriteStatus()
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
        
        // 좋아요 버튼 탭 처리
        input.favoriteButtonTapped
            .bind(with: self) { owner, performanceID in
                owner.handleFavoriteToggle(performanceID: performanceID)
            }
            .disposed(by: disposeBag)
        
        let navigateToProfileEdit = input.bannerTapped
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            userProfile: userProfileRelay.asDriver(),
            cardItems: cardItemsRelay.asDriver(),
            scrollToFirst: scrollToFirstRelay.asSignal(),
            isLoading: isLoadingRelay.asDriver(),
            favoriteStatusChanged: favoriteStatusChangedRelay.asSignal(),
            navigateToProfileEdit: navigateToProfileEdit
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
    
    private func performSearch(category: CategoryCode?, filterState: FilterButtonContainer.FilterState) {
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
    
    private func syncFavoriteStatusToData() {
        let currentBoxOffices = boxOfficeListRelay.value
        guard !currentBoxOffices.isEmpty else { return }
        
        // CardItem으로 변환하면서 찜 상태 반영
        let cardItems = convertToCardItems(from: currentBoxOffices)
        
        // 각 공연의 좋아요 상태를 Signal로 방출 (UI 업데이트용)
        for cardItem in cardItems {
            favoriteStatusChangedRelay.accept((cardItem.id, cardItem.isFavorite))
        }
    }
    
    // 여러 BoxOffice의 좋아요 상태를 한 번에 확인
    private func checkFavoriteStatuses(for boxOffices: [BoxOffice]) {
        let performanceIDs = boxOffices.map { $0.performanceID }
        let favoriteStatuses = checkMultipleFavoriteStatusUseCase.execute(performanceIDs)
        
        // 각 공연의 좋아요 상태를 Signal로 방출
        for (performanceID, isFavorite) in favoriteStatuses {
            favoriteStatusChangedRelay.accept((performanceID, isFavorite))
        }
    }
    
    private func syncFavoriteStatus() {
        let currentBoxOffices = boxOfficeListRelay.value
        guard !currentBoxOffices.isEmpty else { return }
        
        let cardItems = convertToCardItems(from: currentBoxOffices)
        cardItemsRelay.accept(cardItems)
    }
    
    // 좋아요 토글 처리
    private func handleFavoriteToggle(performanceID: String) {
        guard let boxOffice = boxOfficeListRelay.value.first(where: { $0.performanceID == performanceID }) else {
            print("BoxOffice를 찾을 수 없습니다: \(performanceID)")
            return
        }
        
        let favoriteDTO = BoxOfficeToFavoriteDTOMapper.map(from: boxOffice)
        let result = toggleFavoriteUseCase.execute(favoriteDTO)
        
        switch result {
        case .success(let isFavorite):
            favoriteStatusChangedRelay.accept((performanceID, isFavorite))
            
            var currentCardItems = cardItemsRelay.value
            if let index = currentCardItems.firstIndex(where: { $0.id == performanceID }) {
                let updatedCardItem = CardItem(
                    id: currentCardItems[index].id,
                    imageURL: currentCardItems[index].imageURL,
                    title: currentCardItems[index].title,
                    subtitle: currentCardItems[index].subtitle,
                    badge: currentCardItems[index].badge,
                    isFavorite: isFavorite
                )
                currentCardItems[index] = updatedCardItem
                cardItemsRelay.accept(currentCardItems)
            }
            
        case .failure(let error):
            print("좋아요 토글 실패: \(error.localizedDescription)")
        }
    }
    
    private func convertToCardItems(from boxOffices: [BoxOffice]) -> [CardItem] {
        let performanceIDs = boxOffices.map { $0.performanceID }
        let favoriteStatuses = checkMultipleFavoriteStatusUseCase.execute(performanceIDs)
        
        return boxOffices.map { boxOffice in
            let isFavorite = favoriteStatuses[boxOffice.performanceID] ?? false
            return CardItem(
                id: boxOffice.performanceID,
                imageURL: boxOffice.posterURL,
                title: boxOffice.title,
                subtitle: boxOffice.location,
                badge: boxOffice.rank,
                isFavorite: isFavorite
            )
        }
    }
    
    private func updateBoxOfficeDataWithFavoriteStatus(performanceID: String, isFavorite: Bool) {
        // 현재 boxOfficeListRelay의 값을 CardItem으로 변환하면서 상태 업데이트
        let currentBoxOffices = boxOfficeListRelay.value
        let performanceIDs = currentBoxOffices.map { $0.performanceID }
        var favoriteStatuses = checkMultipleFavoriteStatusUseCase.execute(performanceIDs)
        
        // 변경된 상태 반영
        favoriteStatuses[performanceID] = isFavorite
    }
}

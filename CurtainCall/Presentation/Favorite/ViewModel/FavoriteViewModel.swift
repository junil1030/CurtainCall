//
//  FavoriteViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import Foundation
import RxSwift
import RxCocoa

final class FavoriteViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UseCases
    private let fetchFavoritesUseCase: FetchFavoritesUseCase
    private let removeFavoriteUseCase: RemoveFavoriteUseCase
    private let getMonthlyFavoriteCountUseCase: GetMonthlyFavoriteCountUseCase
    private let getFavoriteStatisticsUseCase: GetFavoriteStatisticsUseCase
    
    // MARK: - Streams
    private let favoritesListRelay = BehaviorRelay<[CardItem]>(value: [])
    private let statisticsRelay = BehaviorRelay<FavoriteStatistics>(value: FavoriteStatistics(totalCount: 0, genreCount: [:], areaCount: [:]))
    private let isEmptyRelay = BehaviorRelay<Bool>(value: true)
    private let favoriteRemovedRelay = PublishRelay<String>()
    private let monthlyCountRelay = BehaviorRelay<Int>(value: 0)
    
    // 개별 필터 상태 관리
    private let currentSortTypeRelay = BehaviorRelay<FavoriteFilterCondition.SortType>(value: .latest)
    private let currentGenreRelay = BehaviorRelay<GenreCode?>(value: nil)
    private let currentAreaRelay = BehaviorRelay<AreaCode?>(value: nil)
    
    // MARK: - Input / Output
    struct Input {
        let viewWillAppear: Observable<Void>
        let sortButtonTapped: Observable<FavoriteHeaderView.SortType>
        let genreButtonTapped: Observable<GenreCode?>
        let areaButtonTapped: Observable<AreaCode?>
        let favoriteButtonTapped: Observable<String>
    }
    
    struct Output {
        let favoritesList: Driver<[CardItem]>
        let statistics: Driver<FavoriteStatistics>
        let isEmpty: Driver<Bool>
        let favoriteRemoved: Signal<String>
        let monthlyCount: Driver<Int>
    }
    
    // MARK: - Init
    init(
        fetchFavoritesUseCase: FetchFavoritesUseCase,
        removeFavoriteUseCase: RemoveFavoriteUseCase,
        getMonthlyFavoriteCountUseCase: GetMonthlyFavoriteCountUseCase,
        getFavoriteStatisticsUseCase: GetFavoriteStatisticsUseCase
    ) {
        self.fetchFavoritesUseCase = fetchFavoritesUseCase
        self.removeFavoriteUseCase = removeFavoriteUseCase
        self.getMonthlyFavoriteCountUseCase = getMonthlyFavoriteCountUseCase
        self.getFavoriteStatisticsUseCase = getFavoriteStatisticsUseCase
        super.init()
        
        loadFavorites()
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        
        // viewWillAppear 시 현재 필터로 데이터 새로고침
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                owner.loadFavorites()
            }
            .disposed(by: disposeBag)
        
        // 정렬 타입 변경 처리
        input.sortButtonTapped
            .distinctUntilChanged()
            .map { [weak self] sortType -> FavoriteFilterCondition.SortType in
                guard let self = self else { return .latest }
                return self.mapToFilterSortType(sortType)
            }
            .bind(with: self) { owner, sortType in
                owner.currentSortTypeRelay.accept(sortType)
                owner.loadFavorites()
            }
            .disposed(by: disposeBag)
        
        // 장르 선택 변경 처리
        input.genreButtonTapped
            .distinctUntilChanged { $0?.rawValue == $1?.rawValue }
            .bind(with: self) { owner, genre in
                owner.currentGenreRelay.accept(genre)
                owner.loadFavorites()
            }
            .disposed(by: disposeBag)
        
        // 지역 선택 변경 처리
        input.areaButtonTapped
            .distinctUntilChanged { $0?.rawValue == $1?.rawValue }
            .bind(with: self) { owner, area in
                owner.currentAreaRelay.accept(area)
                owner.loadFavorites()
            }
            .disposed(by: disposeBag)
        
        // 좋아요 버튼 탭 처리 (찜 해제)
        input.favoriteButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, performanceID in
                owner.removeFavorite(performanceID: performanceID)
            })
            .disposed(by: disposeBag)
        
        return Output(
            favoritesList: favoritesListRelay.asDriver(),
            statistics: statisticsRelay.asDriver(),
            isEmpty: isEmptyRelay.asDriver(),
            favoriteRemoved: favoriteRemovedRelay.asSignal(),
            monthlyCount: monthlyCountRelay.asDriver()
        )
    }
    
    // MARK: - Private Methods
    
    // 찜한 공연 목록 로드 - 현재 필터 상태 사용
    private func loadFavorites() {
        // 현재 필터 상태로 FavoriteFilterCondition 생성
        let filter = FavoriteFilterCondition(
            sortType: currentSortTypeRelay.value,
            genre: currentGenreRelay.value,
            area: currentAreaRelay.value
        )
        
        print(filter.sortType, filter.genre?.displayName, filter.area?.displayName)
        
        // UseCase 실행
        let favoriteDTOs = fetchFavoritesUseCase.execute(filter)
        
        // DTO → CardItem 변환
        let cardItems = FavoriteDTOToCardItemMapper.map(from: favoriteDTOs)
        
        // 빈 상태 확인
        let isEmpty = cardItems.isEmpty
        
        // Relay 업데이트
        favoritesListRelay.accept(cardItems)
        isEmptyRelay.accept(isEmpty)
        
        loadMonthlyCount()
        loadStatistics()
    }
    
    private func loadStatistics() {
        let statistics = getFavoriteStatisticsUseCase.execute(())
        statisticsRelay.accept(statistics)
    }
    
    private func loadMonthlyCount() {
        let count = getMonthlyFavoriteCountUseCase.execute(())
        monthlyCountRelay.accept(count)
    }
    
    // 찜 해제
    private func removeFavorite(performanceID: String) {
        let result = removeFavoriteUseCase.execute(performanceID)
        
        switch result {
        case .success:
            // 성공 시 현재 필터 상태로 다시 로드
            loadFavorites()
            favoriteRemovedRelay.accept(performanceID)
            
        case .failure(let error):
            print("찜 해제 실패: \(error.localizedDescription)")
            // TODO: 에러 처리 (Toast 또는 Alert)
        }
    }
    
    // HeaderView의 SortType을 ViewModel의 SortType으로 변환
    private func mapToFilterSortType(_ headerSortType: FavoriteHeaderView.SortType) -> FavoriteFilterCondition.SortType {
        switch headerSortType {
        case .latest:
            return .latest
        case .oldest:
            return .oldest
        case .nameAscending:
            return .nameAscending
        case .nameDescending:
            return .nameDescending
        }
    }
}

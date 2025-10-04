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
    
    // MARK: - Filter State
    private let currentFilterRelay = BehaviorRelay<FavoriteFilterCondition>(value: .default)
    
    // MARK: - Input / Output
    struct Input {
        let sortTypeChanged: Observable<FavoriteFilterCell.SortType>
        let genreSelected: Observable<GenreCode?>
        let areaSelected: Observable<AreaCode?>
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
        
        loadFavorites(with: .default)
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        
        // 정렬 타입 변경 처리
        input.sortTypeChanged
            .withLatestFrom(currentFilterRelay) { sortType, filter in
                FavoriteFilterCondition(
                    sortType: self.mapToFilterSortType(sortType),
                    genre: filter.genre,
                    area: filter.area
                )
            }
            .bind(with: self) { owner, newFilter in
                owner.currentFilterRelay.accept(newFilter)
                owner.loadFavorites(with: newFilter)
            }
            .disposed(by: disposeBag)
        
        // 장르 선택 변경 처리
        input.genreSelected
            .withLatestFrom(currentFilterRelay) { genre, filter in
                FavoriteFilterCondition(
                    sortType: filter.sortType,
                    genre: genre,
                    area: filter.area
                )
            }
            .bind(with: self) { owner, newFilter in
                owner.currentFilterRelay.accept(newFilter)
                owner.loadFavorites(with: newFilter)
            }
            .disposed(by: disposeBag)
        
        // 지역 선택 변경 처리
        input.areaSelected
            .withLatestFrom(currentFilterRelay) { area, filter in
                FavoriteFilterCondition(
                    sortType: filter.sortType,
                    genre: filter.genre,
                    area: area
                )
            }
            .bind(with: self) { owner, newFilter in
                owner.currentFilterRelay.accept(newFilter)
                owner.loadFavorites(with: newFilter)
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
    
    // 찜한 공연 목록 로드
    private func loadFavorites(with filter: FavoriteFilterCondition) {
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
    
    // 이번 달 찜 개수 로드
    private func loadMonthlyCount() {
        let count = getMonthlyFavoriteCountUseCase.execute(())
        monthlyCountRelay.accept(count)
    }
    
    // 통계 정보 로드
    private func loadStatistics() {
        let statistics = getFavoriteStatisticsUseCase.execute(())
        statisticsRelay.accept(statistics)
    }
    
    // 찜 해제
    private func removeFavorite(performanceID: String) {
        let result = removeFavoriteUseCase.execute(performanceID)
        
        switch result {
        case .success:
            // 성공 시 현재 필터로 다시 로드
            loadFavorites(with: currentFilterRelay.value)
            favoriteRemovedRelay.accept(performanceID)
            
        case .failure(let error):
            print("찜 해제 실패: \(error.localizedDescription)")
            // TODO: 에러 처리 (Toast 또는 Alert)
        }
    }
    
    // FavoriteFilterCell.SortType → FavoriteFilterCondition.SortType 변환
    private func mapToFilterSortType(_ sortType: FavoriteFilterCell.SortType) -> FavoriteFilterCondition.SortType {
        switch sortType {
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

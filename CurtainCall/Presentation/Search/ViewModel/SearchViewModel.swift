//
//  SearchViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 10/01/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UseCases
    private let addRecentSearchUseCase: AddRecentSearchUseCase
    private let getRecentSearchesUseCase: GetRecentSearchesUseCase
    private let deleteRecentSearchUseCase: DeleteRecentSearchUseCase
    private let clearAllRecentSearchesUseCase: ClearAllRecentSearchesUseCase
    
    // MARK: - Streams
    private let searchResultsRelay = BehaviorRelay<[SearchResult]>(value: [])
    private let recentSearchesRelay = BehaviorRelay<[RecentSearch]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<(NetworkError, isLoadMore: Bool)>()
    private let currentKeywordRelay = BehaviorRelay<String>(value: "")
    private let currentFilterStateRelay = BehaviorRelay<FilterButtonCell.FilterState>(value: FilterButtonCell.FilterState())
    
    // MARK: - Pagenation State
    private let currentPage = BehaviorRelay<Int>(value: 1)
    private let isLoadingMore = BehaviorRelay<Bool>(value: false)
    private let hasMoreData = BehaviorRelay<Bool>(value: true)

    
    // MARK: - Input / Output
    struct Input {
        let viewWillAppear: Observable<Void>
        let searchKeyword: Observable<String>
        let filterStateChanged: Observable<FilterButtonCell.FilterState>
        let getCurrentKeyword: Observable<String>
        let recentSearchSelected: Observable<RecentSearch>
        let deleteRecentSearch: Observable<RecentSearch>
        let clearAllRecentSearches: Observable<Void>
        let loadMore: Observable<Void>
    }
    
    struct Output {
        let searchResults: Driver<[SearchResult]>
        let recentSearches: Driver<[RecentSearch]>
        let currentSearchKeyword: Driver<String>
        let isLoading: Driver<Bool>
        let error: Signal<(NetworkError, isLoadMore: Bool)>
    }
    
    init(
        addRecentSearchUseCase: AddRecentSearchUseCase,
        getRecentSearchesUseCase: GetRecentSearchesUseCase,
        deleteRecentSearchUseCase: DeleteRecentSearchUseCase,
        clearAllRecentSearchesUseCase: ClearAllRecentSearchesUseCase
    ) {
        self.addRecentSearchUseCase = addRecentSearchUseCase
        self.getRecentSearchesUseCase = getRecentSearchesUseCase
        self.deleteRecentSearchUseCase = deleteRecentSearchUseCase
        self.clearAllRecentSearchesUseCase = clearAllRecentSearchesUseCase
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                owner.loadRecentSearches()
            }
            .disposed(by: disposeBag)
        
        // 검색 버튼 탭 처리
        input.searchKeyword
            .withUnretained(self)
            .filter { owner, keyword in
                return owner.isValidKeyword(keyword)
            }
            .bind { owner, keyword in
                owner.currentKeywordRelay.accept(keyword)
                
                owner.currentPage.accept(1)
                owner.hasMoreData.accept(true)
                owner.searchResultsRelay.accept([])
                
                let filterState = owner.currentFilterStateRelay.value
                owner.performSearch(keyword: keyword, filterState: filterState, page: 1, isLoadMore: false)
                
                owner.saveSearchKeyword(keyword)
            }
            .disposed(by: disposeBag)
        
        input.filterStateChanged
            .skip(1)
            .distinctUntilChanged { prev, curr in
                return prev.area?.rawValue == curr.area?.rawValue &&
                       prev.dateType == curr.dateType &&
                       prev.startDate == curr.startDate &&
                       prev.endDate == curr.endDate
            }
            .withLatestFrom(input.getCurrentKeyword) { ($0, $1) }
            .withUnretained(self)
            .filter { owner, data in
                let (_, keyword) = data
                return owner.isValidKeyword(keyword)
            }
            .bind { owner, data in
                let (filterState, keyword) = data
                owner.currentFilterStateRelay.accept(filterState)
                
                owner.currentPage.accept(1)
                owner.hasMoreData.accept(true)
                owner.searchResultsRelay.accept([])
                
                owner.performSearch(keyword: keyword, filterState: filterState, page: 1, isLoadMore: false)
            }
            .disposed(by: disposeBag)
        
        input.recentSearchSelected
            .map { $0.keyword }
            .bind(with: self) { owner, keyword in
                owner.currentKeywordRelay.accept(keyword)
                
                owner.currentPage.accept(1)
                owner.hasMoreData.accept(true)
                owner.searchResultsRelay.accept([])
                
                let filterState = owner.currentFilterStateRelay.value
                owner.performSearch(keyword: keyword, filterState: filterState, page: 1, isLoadMore: false)
                
                owner.saveSearchKeyword(keyword)
            }
            .disposed(by: disposeBag)
        
        input.loadMore
            .withUnretained(self)
            .filter { owner, _ in
                return !owner.isLoadingMore.value && owner.hasMoreData.value && !owner.currentKeywordRelay.value.isEmpty
            }
            .bind { owner, _ in
                let nextpage = owner.currentPage.value + 1
                owner.currentPage.accept(nextpage)
                
                let keyword = owner.currentKeywordRelay.value
                let filterState = owner.currentFilterStateRelay.value
                owner.performSearch(keyword: keyword, filterState: filterState, page: nextpage, isLoadMore: true)
            }
            .disposed(by: disposeBag)

        input.deleteRecentSearch
            .map { $0.keyword }
            .bind(with: self) { owner, keyword in
                let result = owner.deleteRecentSearchUseCase.execute(keyword)
                
                switch result {
                case .success:
                    owner.loadRecentSearches()
                case .failure(let error):
                    print("검색어 삭제 실패: \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
        
        input.clearAllRecentSearches
            .bind(with: self) { owner, _ in
                let result = owner.clearAllRecentSearchesUseCase.execute(())
                
                switch result {
                case .success:
                    owner.loadRecentSearches()
                case .failure(let error):
                    print("전체 검색어 삭제 실패: \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            searchResults: searchResultsRelay.asDriver(onErrorJustReturn: []),
            recentSearches: recentSearchesRelay.asDriver(),
            currentSearchKeyword: currentKeywordRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asSignal()
        )
    }
    
    // MARK: - Private Methods
    
    /// 유효한 검색어인지 확인
    private func isValidKeyword(_ keyword: String) -> Bool {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedKeyword.isEmpty
    }
    
    /// 검색 수행
    private func performSearch(keyword: String, filterState: FilterButtonCell.FilterState, page: Int, isLoadMore: Bool) {
        
        if isLoadMore {
            isLoadingMore.accept(true)
        } else {
            isLoadingRelay.accept(true)
        }
        
        let startDateString = filterState.startDate
        let endDateString = filterState.endDate
        let areaString = filterState.area
        let pageString = String(page)
        
        CustomObservable.request(
            .searchPerformance(
                startDate: startDateString,
                endDate: endDateString,
                page: pageString,
                keyword: keyword,
                area: areaString
            ),
            responseType: SearchResponseDTO.self
        )
        .subscribe(with: self) { owner, response in
            if isLoadMore {
                owner.isLoadingMore.accept(false)
            } else {
                owner.isLoadingRelay.accept(false)
            }
            
            let newResults = SearchResultMapper.map(from: response.dbs.db)
            
            if newResults.isEmpty {
                owner.hasMoreData.accept(false)
                
                if isLoadMore {
                    // 추가 로딩에서 빈 응답 → 기존 데이터 유지
                    return
                } else {
                    // 첫 검색에서 0건 → 빈 배열로 업데이트
                    owner.searchResultsRelay.accept([])
                    return
                }
            }
            
            if isLoadMore {
                let currentResults = owner.searchResultsRelay.value
                owner.searchResultsRelay.accept(currentResults + newResults)
            } else {
                owner.searchResultsRelay.accept(newResults)
            }
            
        } onFailure: { owner, error in
            if isLoadMore {
                owner.isLoadingMore.accept(false)
            } else {
                owner.isLoadingRelay.accept(false)
            }
            
            if let networkError = error as? NetworkError {
                owner.errorRelay.accept((networkError, isLoadMore: isLoadMore))
            }

            if !isLoadMore {
                owner.searchResultsRelay.accept([])
            }
        }
        .disposed(by: disposeBag)
    }
    
    // 최근 검색어 로드
    private func loadRecentSearches() {
        let searches = getRecentSearchesUseCase.execute(())
        recentSearchesRelay.accept(searches)
    }
    
    // 검색어 저장 및 최근 검색어 목록 갱신
    private func saveSearchKeyword(_ keyword: String) {
        let result = addRecentSearchUseCase.execute(keyword)
        
        switch result {
        case .success:
            loadRecentSearches()
        case .failure(let error):
            print("검색어 저장 실패: \(error.localizedDescription)")
        }
    }
}

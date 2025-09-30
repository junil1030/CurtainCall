//
//  SearchViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Input / Output
    struct Input {
        let searchButtonTapped: Observable<String>
        let filterChanged: Observable<FilterButtonContainer.FilterState>
        let selectedSearchResult: Observable<SearchResult>
        let recentSearchTapped: Observable<RecentSearch>
        let deleteRecentSearch: Observable<RecentSearch>
        let deleteAllRecentSearches: Observable<Void>
    }
    
    struct Output {
        let searchResults: Driver<[SearchResult]>
        let recentSearches: Driver<[RecentSearch]>
        let isLoading: Driver<Bool>
        let hasSearched: Driver<Bool>  // 검색을 했는지 여부
        let error: Signal<String>
    }
    
    // MARK: - Streams
    private let searchResultsRelay = BehaviorRelay<[SearchResult]>(value: [])
    private let recentSearchesRelay = BehaviorRelay<[RecentSearch]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let hasSearchedRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    
    // 현재 검색어 추적
    private let currentKeywordRelay = BehaviorRelay<String>(value: "")
    
    // MARK: - Init
    override init() {
        super.init()
        loadMockRecentSearches()
    }
    
    func transform(input: Input) -> Output {
        
        // 검색 버튼 탭 - 기본 필터값으로 검색
        input.searchButtonTapped
            .do(onNext: { keyword in
                print("🔍 [ViewModel] 검색 버튼 탭 - 키워드: '\(keyword)'")
            })
            .withUnretained(self)
            .subscribe(onNext: { owner, keyword in
                owner.currentKeywordRelay.accept(keyword)
                // 기본 필터값 생성
                let defaultFilter = FilterButtonContainer.FilterState()
                owner.performSearch(keyword: keyword, filterState: defaultFilter)
            })
            .disposed(by: disposeBag)
        
        // 필터 변경 - 현재 검색어로 재검색
        input.filterChanged
            .skip(1)  // 초기값 스킵
            .distinctUntilChanged()
            .withLatestFrom(currentKeywordRelay) { ($1, $0) }  // (keyword, filterState)
            .filter { keyword, _ in !keyword.isEmpty }  // 검색어가 있을 때만
            .withUnretained(self)
            .subscribe(onNext: { owner, data in
                let (keyword, filterState) = data
                print("🔍 [ViewModel] 필터 변경 - 재검색")
                owner.performSearch(keyword: keyword, filterState: filterState)
            })
            .disposed(by: disposeBag)
        
        // 최근 검색어 탭 - 기본 필터값으로 검색
        input.recentSearchTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, recentSearch in
                print("🔍 [ViewModel] 최근 검색어 탭: '\(recentSearch.keyword)'")
                owner.currentKeywordRelay.accept(recentSearch.keyword)
                let defaultFilter = FilterButtonContainer.FilterState()
                owner.performSearch(keyword: recentSearch.keyword, filterState: defaultFilter)
            })
            .disposed(by: disposeBag)
        
        // 최근 검색어 개별 삭제
        input.deleteRecentSearch
            .withUnretained(self)
            .subscribe(onNext: { owner, search in
                owner.deleteRecentSearch(search)
            })
            .disposed(by: disposeBag)
        
        // 최근 검색어 전체 삭제
        input.deleteAllRecentSearches
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.recentSearchesRelay.accept([])
            })
            .disposed(by: disposeBag)
        
        return Output(
            searchResults: searchResultsRelay.asDriver(),
            recentSearches: recentSearchesRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            hasSearched: hasSearchedRelay.asDriver(),
            error: errorRelay.asSignal()
        )
    }
    
    // MARK: - Private Methods
    private func performSearch(keyword: String, filterState: FilterButtonContainer.FilterState) {
        print("🔍 [ViewModel] performSearch 시작")
        print("   - 키워드: '\(keyword)'")
        print("   - 필터: \(filterState.area?.displayName ?? "전국"), \(filterState.startDate)~\(filterState.endDate)")
        
        // 빈 검색어면 검색하지 않음
        guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ [ViewModel] 빈 검색어 - 검색 취소")
            return
        }
        
        print("✅ [ViewModel] 검색 수행")
        isLoadingRelay.accept(true)
        hasSearchedRelay.accept(true)  // 검색 시작
        
        // 최근 검색어에 추가 (중복 제거)
        addRecentSearch(keyword: keyword)
        
        print("🌐 [ViewModel] API 호출 시작")
        
        // API 호출
        CustomObservable.request(
            .searchPerformance(
                startDate: filterState.startDate,
                endDate: filterState.endDate,
                page: "1",
                keyword: keyword
            ),
            responseType: SearchResponseDTO.self
        )
        .subscribe(with: self) { owner, response in
            print("✅ [ViewModel] API 응답 성공")
            owner.isLoadingRelay.accept(false)
            let results = SearchResultMapper.map(from: response.dbs.db)
            print("   - 결과 개수: \(results.count)")
            owner.searchResultsRelay.accept(results)
        } onFailure: { owner, error in
            print("❌ [ViewModel] API 응답 실패: \(error)")
            owner.isLoadingRelay.accept(false)
            owner.searchResultsRelay.accept([])
            
            if let networkError = error as? NetworkError {
                owner.errorRelay.accept(networkError.localizedDescription)
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func addRecentSearch(keyword: String) {
        var searches = recentSearchesRelay.value
        
        // 중복 제거
        searches.removeAll { $0.keyword == keyword }
        
        // 새로운 검색어 추가
        let newSearch = RecentSearch(keyword: keyword)
        searches.insert(newSearch, at: 0)
        
        // 최대 5개까지만 유지
        if searches.count > 5 {
            searches = Array(searches.prefix(5))
        }
        
        recentSearchesRelay.accept(searches)
    }
    
    private func deleteRecentSearch(_ search: RecentSearch) {
        var searches = recentSearchesRelay.value
        searches.removeAll { $0.id == search.id }
        recentSearchesRelay.accept(searches)
    }
    
    private func loadMockRecentSearches() {
        // Mock 데이터 (나중에 Realm으로 대체)
        let mockSearches: [RecentSearch] = [
            RecentSearch(keyword: "테스트1"),
            RecentSearch(keyword: "테스트2"),
            RecentSearch(keyword: "추후 렘에서 가져오도록"),
            RecentSearch(keyword: "변경필요"),
        ]
        recentSearchesRelay.accept(mockSearches)
    }
}

// MARK: - FilterState Equatable
extension FilterButtonContainer.FilterState: Equatable {
    public static func == (lhs: FilterButtonContainer.FilterState, rhs: FilterButtonContainer.FilterState) -> Bool {
        return lhs.area?.rawValue == rhs.area?.rawValue &&
               lhs.dateType == rhs.dateType &&
               lhs.startDate == rhs.startDate &&
               lhs.endDate == rhs.endDate &&
               lhs.isReset == rhs.isReset
    }
}

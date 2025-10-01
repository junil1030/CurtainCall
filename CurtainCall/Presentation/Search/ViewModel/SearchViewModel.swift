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
    private let currentPage = BehaviorRelay<Int>(value: 1)
    
    // MARK: - Streams
    private let searchResultsRelay = PublishRelay<[SearchResult]>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<NetworkError>()
    private let currentKeywordRelay = BehaviorRelay<String>(value: "")
    private let currentFilterStateRelay = BehaviorRelay<FilterButtonContainer.FilterState>(value: FilterButtonContainer.FilterState())
    
    // MARK: - Input / Output
    struct Input {
        let searchKeyword: Observable<String>
        let filterStateChanged: Observable<FilterButtonContainer.FilterState>
        let getCurrentKeyword: Observable<String>
    }
    
    struct Output {
        let searchResults: Driver<[SearchResult]>
        let isLoading: Driver<Bool>
        let error: Signal<NetworkError>
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        
        // 검색 버튼 탭 처리
        input.searchKeyword
            .withUnretained(self)
            .filter { owner, keyword in
                return owner.isValidKeyword(keyword)
            }
            .bind { owner, keyword in
                owner.currentKeywordRelay.accept(keyword)
                owner.currentPage.accept(1)
                let filterState = owner.currentFilterStateRelay.value
                owner.performSearch(keyword: keyword, filterState: filterState, page: 1)
            }
            .disposed(by: disposeBag)
        
        input.filterStateChanged
            .skip(1) // 초기값 스킵
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
                owner.performSearch(keyword: keyword, filterState: filterState, page: 1)
            }
            .disposed(by: disposeBag)

        
        return Output(
            searchResults: searchResultsRelay.asDriver(onErrorJustReturn: []),
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
    private func performSearch(keyword: String, filterState: FilterButtonContainer.FilterState, page: Int) {
        isLoadingRelay.accept(true)
        
        let startDateString = filterState.startDate
        let endDateString = filterState.endDate
        let pageString = String(page)
        
        CustomObservable.request(
            .searchPerformance(
                startDate: startDateString,
                endDate: endDateString,
                page: pageString,
                keyword: keyword
            ),
            responseType: SearchResponseDTO.self
        )
        .subscribe(with: self) { owner, response in
            owner.isLoadingRelay.accept(false)
            
            let searchResults = SearchResultMapper.map(from: response.dbs.db)
            owner.searchResultsRelay.accept(searchResults)
            
        } onFailure: { owner, error in
            owner.isLoadingRelay.accept(false)
            
            if let networkError = error as? NetworkError {
                owner.errorRelay.accept(networkError)
            }
            owner.searchResultsRelay.accept([])
        }
        .disposed(by: disposeBag)
    }}

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
    private let searchResultsRelay = BehaviorRelay<[SearchResult]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<NetworkError>()
    
    // MARK: - Input / Output
    struct Input {
        let searchButtonTapped: Observable<String?>
    }
    
    struct Output {
        let searchResults: Driver<[SearchResult]>
        let isLoading: Driver<Bool>
        let error: Signal<NetworkError>
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        
        // 검색 버튼 탭 처리
        input.searchButtonTapped
            .compactMap { $0 } // nil 제거
            .filter { [weak self] keyword in
                self?.isValidKeyword(keyword) ?? false
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, keyword in
                owner.currentPage.accept(1) // 새 검색 시 페이지 초기화
                owner.performSearch(keyword: keyword, page: 1)
            })
            .disposed(by: disposeBag)
        
        return Output(
            searchResults: searchResultsRelay.asDriver(),
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
    private func performSearch(keyword: String, page: Int) {
        isLoadingRelay.accept(true)
        
        // 날짜 범위 설정 (현재 날짜 기준 ±1년)
        let today = Date()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .year, value: -1, to: today) ?? today
        let endDate = calendar.date(byAdding: .year, value: 1, to: today) ?? today
        
        let startDateString = startDate.toKopisAPIFormatt
        let endDateString = endDate.toKopisAPIFormatt
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
    }
}

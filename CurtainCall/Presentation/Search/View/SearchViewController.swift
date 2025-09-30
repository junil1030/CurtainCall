//
//  SearchViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {
    
    // MARK: - Properties
    private let searchView = SearchView()
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = searchView
    }
    
    override func setupLayout() {
        super.setupLayout()
        setupNavigationBar()
    }
    
    override func setupBind() {
        super.setupBind()
        
        print("🔍 [ViewController] setupBind 시작")
        
        let input = SearchViewModel.Input(
            searchButtonTapped: searchView.searchButtonTapped
                .do(onNext: { keyword in
                    print("🔍 [ViewController] Input - searchButtonTapped: '\(keyword)'")
                }),
            filterChanged: searchView.filterChanged
                .do(onNext: { state in
                    print("🔍 [ViewController] Input - filterChanged")
                }),
            selectedSearchResult: searchView.selectedSearchResult,
            recentSearchTapped: searchView.recentSearchTapped
                .do(onNext: { search in
                    print("🔍 [ViewController] Input - recentSearchTapped: '\(search.keyword)'")
                }),
            deleteRecentSearch: searchView.deleteRecentSearch,
            deleteAllRecentSearches: searchView.deleteAllSearches
        )
        
        let output = viewModel.transform(input: input)
        
        // 검색 결과 + 검색 여부를 함께 전달
        Observable.combineLatest(
            output.searchResults.asObservable(),
            output.hasSearched.asObservable()
        )
        .subscribe(with: self) { owner, data in
            let (results, hasSearched) = data
            print("🔍 [ViewController] Output - searchResults: \(results.count)개, hasSearched: \(hasSearched)")
            owner.searchView.updateSearchResults(results, hasSearched: hasSearched)
        }
        .disposed(by: disposeBag)
        
        // 최근 검색어 바인딩
        output.recentSearches
            .drive(with: self) { owner, searches in
                print("🔍 [ViewController] Output - recentSearches 수신: \(searches.count)개")
                owner.searchView.updateRecentSearches(searches)
            }
            .disposed(by: disposeBag)
        
        // 로딩 상태 바인딩
        output.isLoading
            .drive(with: self) { owner, isLoading in
                print("🔍 [ViewController] Output - isLoading: \(isLoading)")
                // TODO: 로딩 인디케이터 표시/숨김
            }
            .disposed(by: disposeBag)
        
        // 에러 처리
        output.error
            .emit(with: self) { owner, errorMessage in
                print("❌ [ViewController] Output - error: \(errorMessage)")
                // TODO: 에러 알럿 표시
            }
            .disposed(by: disposeBag)
        
        // 검색 결과 선택 시 상세 화면으로 이동
        searchView.selectedSearchResult
            .subscribe(with: self) { owner, result in
                print("🔍 [ViewController] 검색 결과 선택: \(result.title)")
                let vm = DetailViewModel(performanceID: result.id)
                let vc = DetailViewController(viewModel: vm)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        title = "검색"
    }
}

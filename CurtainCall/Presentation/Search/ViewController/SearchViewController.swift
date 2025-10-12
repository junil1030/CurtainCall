//
//  SearchViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {
    
    // MARK: - Properties
    private let searchView = SearchView()
    private let viewModel: SearchViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Subjects
    private let viewWillAppearSubject = PublishSubject<Void>()
    
    // MARK: - Init
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
   required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        view = searchView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearSubject.onNext(())
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.title = "검색"
    }
    
    override func setupBind() {
        super.setupBind()
        
        let searchKeyword = Observable.merge(
            searchView.searchButtonTapped.compactMap { $0 },
            searchView.searchTriggered
        )
        
        let input = SearchViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            searchKeyword: searchKeyword,
            filterStateChanged: searchView.filterState,
            getCurrentKeyword: Observable.just(searchView.getCurrentKeyword())
                .concat(searchView.filterState.map { [weak self] _ in
                    self?.searchView.getCurrentKeyword() ?? ""
                }),
            recentSearchSelected: searchView.selectedRecentKeyowrd,
            deleteRecentSearch: searchView.deleteRecentSearch,
            clearAllRecentSearches: searchView.deleteAllRecentSearches
        )
        
        let output = viewModel.transform(input: input)
        
        output.recentSearches
            .drive(with: self) { owner, searches in
                owner.searchView.updateRecentSearches(searches)
            }
            .disposed(by: disposeBag)
        
        // 검색 결과 바인딩
        output.searchResults
            .drive(with: self) { owner, results in
                let keyword = owner.searchView.getCurrentKeyword()
                owner.searchView.updateSearchResults(results: results, keyword: keyword)
            }
            .disposed(by: disposeBag)
        
        // 로딩 상태 바인딩
        output.isLoading
            .drive(with: self) { owner, isLoading in
                // TODO: 로딩 인디케이터 표시/숨김
                print("로딩 상태: \(isLoading)")
            }
            .disposed(by: disposeBag)
        
        // 에러 처리
        output.error
            .emit(with: self) { owner, error in
                // TODO: 에러 알럿 표시
                print("에러: \(error.localizedDescription)")
            }
            .disposed(by: disposeBag)
        
        searchView.selectedSearchResult
            .bind(with: self) { owner, searchResult in
                let repository = FavoriteRepository()
                let toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: repository)
                let checkFavoriteUseCase = CheckFavoriteStatusUseCase(repository: repository)
                let vm = DetailViewModel(performanceID: searchResult.id, toggleFavoriteUseCase: toggleFavoriteUseCase, checkFavoriteStatusUseCase: checkFavoriteUseCase)
                let vc = DetailViewController(viewModel: vm)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

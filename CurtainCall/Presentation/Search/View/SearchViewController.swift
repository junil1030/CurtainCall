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
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func loadView() {
        view = searchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 탭바 숨기기
        hidesBottomBarWhenPushed = true
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.title = "검색"
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = SearchViewModel.Input(
            searchButtonTapped: searchView.searchButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        // 검색 결과 바인딩
        output.searchResults
            .drive(with: self) { owner, results in
                // TODO: 검색 결과로 콜렉션뷰 업데이트
                print("검색 결과: \(results.count)개")
                owner.searchView.updateSearchResults(results: results)
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
    }
}

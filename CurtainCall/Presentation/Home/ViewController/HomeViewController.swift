//
//  HomeViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 9/26/25.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController {
    
    // MARK: - Properties
    private let homeView = HomeView()
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    private let container = DIContainer.shared
    
    // MARK: - Subjects
    private let viewWillAppearSubject = PublishSubject<Void>()
    
    // MARK: - Init
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        super.loadView()
        
        view = homeView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationbarHidden(true)
        viewWillAppearSubject.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNavigationbarHidden(false)
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = HomeViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            selectedCard: homeView.selectedCard,
            selectedCategory: homeView.selectedCategory,
            filterState: homeView.filterState,
            searchButtonTapped: homeView.searchButtonTapped,
            headerFavoriteButtonTapped: homeView.headerFavoriteButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        output.userProfile
            .drive(with: self) { owner, profile in
                guard let profile = profile else { return }
                owner.homeView.updateGreetingText(nickname: profile.nickname)
            }
            .disposed(by: disposeBag)
        
        output.cardItems
            .drive(with: self) { owner, cardItems in
                owner.homeView.updateCardItems(cardItems)
            }
            .disposed(by: disposeBag)
        
        output.scrollToFirst
             .emit(with: self) { owner, _ in
                 owner.homeView.scrollToFirstCard()
             }
             .disposed(by: disposeBag)
        
        // 로딩 상태 처리 (추후 로딩 인디케이터 추가 시 사용)
        output.isLoading
            .drive(with: self) { owner, isLoading in
                // TODO: 로딩 인디케이터 표시/숨김
                print("로딩 상태: \(isLoading)")
            }
            .disposed(by: disposeBag)
        
        homeView.selectedCard
            .bind(with: self) { owner, cardItem in
                owner.navigateToDetailView(with: cardItem)
            }
            .disposed(by: disposeBag)
        
        // 헤더 검색 버튼 처리
        homeView.searchButtonTapped
            .bind(with: self) { owner, _ in
                owner.navigateToSearchView()
            }
            .disposed(by: disposeBag)
        
        // 헤더 찜 버튼 처리
        homeView.headerFavoriteButtonTapped
            .bind(with: self) { owner, _ in
                owner.navigateToFavoriteView()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Navigation
extension HomeViewController {
    
    private func navigateToSearchView() {
        let viewModel = container.makeSearchViewModel()
        let viewController = SearchViewController(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToDetailView(with item: CardItem) {
        let viewModel = container.makeDetailViewModel(performanceID: item.id)
        let viewController = DetailViewController(viewModel: viewModel)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToFavoriteView() {
        let viewModel = container.makeFavoriteViewModel()
        let viewController = FavoriteViewController(viewModel: viewModel)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToProfileEdit() {
        let viewModel = container.makeProfileEditViewModel()
        let viewController = ProfileEditViewController(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }

}

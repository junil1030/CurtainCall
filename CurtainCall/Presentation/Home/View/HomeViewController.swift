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
    
    // MARK: - UI Components
    private let searchButton = UIBarButtonItem(
        image: UIImage(systemName: "magnifyingglass"),
        style: .plain,
        target: nil,
        action: nil
    )
    
    private let favoriteButton = UIBarButtonItem(
        image: UIImage(systemName: "heart"),
        style: .plain,
        target: nil,
        action: nil
    )
    
    // MARK: - Init
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view = homeView
    }
    
    override func setupLayout() {
        super.setupLayout()
        setupNavigationBar()
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = HomeViewModel.Input(
            selectedCard: homeView.selectedCard,
            selectedCategory: homeView.selectedCategory,
            filterState: homeView.filterState,
            favoriteButtonTapped: homeView.favoriteButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        output.boxOfficeList
            .drive(with: self) { owner, list in
                owner.homeView.updateBoxOfficeList(list)
            }
            .disposed(by: disposeBag)
        
        // 좋아요 상태 변경 처리 추가
        output.favoriteStatusChanged
            .emit(with: self) { owner, data in
                let (performanceID, isFavorite) = data
                owner.homeView.updateFavoriteStatus(performanceID: performanceID, isFavorite: isFavorite)
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
                let repository = FavoriteRepository()
                let toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: repository)
                let checkFavoriteUseCase = CheckFavoriteStatusUseCase(repository: repository)
                let vm = DetailViewModel(performanceID: cardItem.id, toggleFavoriteUseCase: toggleFavoriteUseCase, checkFavoriteStatusUseCase: checkFavoriteUseCase)
                let vc = DetailViewController(viewModel: vm)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = SearchViewController()
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = FavoriteViewController()
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "커튼콜"
        titleLabel.font = .ccTitle1Bold
        titleLabel.textColor = .ccPrimary
        
        let leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        searchButton.tintColor = .ccPrimary
        favoriteButton.tintColor = .ccPrimary
        navigationItem.rightBarButtonItems = [searchButton, favoriteButton]
    }
}

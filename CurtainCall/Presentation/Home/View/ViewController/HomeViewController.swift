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
    
    // MARK: - Subjects
    private let viewWillAppearSubject = PublishSubject<Void>()
    
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
    
    let crashButton = UIBarButtonItem(
        title: "crash",
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
    
    // MARK: - Life Cycle
    override func loadView() {
        super.loadView()
        
        view = homeView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext(())
    }
    
    override func setupLayout() {
        super.setupLayout()
        setupNavigationBar()
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = HomeViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            selectedCard: homeView.selectedCard,
            selectedCategory: homeView.selectedCategory,
            filterState: homeView.filterState,
            favoriteButtonTapped: homeView.favoriteButtonTapped,
            bannerTapped: homeView.bannerTapped
        )
        
        let output = viewModel.transform(input: input)
        
        output.userProfile
            .drive(with: self) { owner, profile in
                guard let profile = profile else { return }
                owner.homeView.updateProfileBanner(
                    nickname: profile.nickname,
                    profileImageURL: profile.profileImageURL
                )
            }
            .disposed(by: disposeBag)
        
        output.cardItems
            .drive(with: self) { owner, cardItems in
                owner.homeView.updateCardItems(cardItems)
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
        
        output.navigateToProfileEdit
            .emit(with: self) { owner, _ in
                owner.navigateToProfileEdit()
            }
            .disposed(by: disposeBag)
        
        // MARK: - TODO: viewmodel input으로 집어넣기
        homeView.selectedCard
            .bind(with: self) { owner, cardItem in
                owner.navigateToDetailView(with: cardItem)
            }
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .bind(with: self) { owner, _ in
                let repository = RecentSearchRepository()
                
                let addRecentSearchUseCase = AddRecentSearchUseCase(repository: repository)
                let getRecentSearchesUseCase = GetRecentSearchesUseCase(repository: repository)
                let deleteRecentSearchUseCase = DeleteRecentSearchUseCase(repository: repository)
                let clearAllRecentSearchesUseCase = ClearAllRecentSearchesUseCase(repository: repository)
                
                let viewModel = SearchViewModel(
                    addRecentSearchUseCase: addRecentSearchUseCase,
                    getRecentSearchesUseCase: getRecentSearchesUseCase,
                    deleteRecentSearchUseCase: deleteRecentSearchUseCase,
                    clearAllRecentSearchesUseCase: clearAllRecentSearchesUseCase
                )
                let viewController = SearchViewController(viewModel: viewModel)
                
                owner.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigateToFavoriteView()
            }
            .disposed(by: disposeBag)
        
        crashButton.rx.tap
            .bind { _ in
                let numbers = [0]
                let _ = numbers[1]
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
        navigationItem.rightBarButtonItems = [searchButton, favoriteButton, crashButton]
    }
    
    private func navigateToDetailView(with item: CardItem) {
        let repository = FavoriteRepository()
        
        let toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: repository)
        let checkFavoriteUseCase = CheckFavoriteStatusUseCase(repository: repository)
        
        let viewModel = DetailViewModel(performanceID: item.id, toggleFavoriteUseCase: toggleFavoriteUseCase, checkFavoriteStatusUseCase: checkFavoriteUseCase)
        
        let viewController = DetailViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToFavoriteView() {
        let repository = FavoriteRepository()
        
        let fetchFavoritesUseCase = FetchFavoritesUseCase(repository: repository)
        let removeFavoriteUseCase = RemoveFavoriteUseCase(repository: repository)
        let getMonthlyFavoriteCountUseCase = GetMonthlyFavoriteCountUseCase(repository: repository)
        let getFavoriteStatisticsUseCase = GetFavoriteStatisticsUseCase(repository: repository)
        
        let viewModel = FavoriteViewModel(
            fetchFavoritesUseCase: fetchFavoritesUseCase,
            removeFavoriteUseCase: removeFavoriteUseCase,
            getMonthlyFavoriteCountUseCase: getMonthlyFavoriteCountUseCase,
            getFavoriteStatisticsUseCase: getFavoriteStatisticsUseCase
        )
        
        let viewController = FavoriteViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToProfileEdit() {
        let repository = UserRepository()
        
        let getUserProfileUseCase = GetUserProfileUseCase(repository: repository)
        let updateProfileImageUseCase = UpdateProfileImageUseCase(repository: repository)
        let updateNicknameUseCase = UpdateNicknameUseCase(repository: repository)
        
        let viewModel = ProfileEditViewModel(
            getUserProfileUseCase: getUserProfileUseCase,
            updateProfileImageUseCase: updateProfileImageUseCase,
            updateNicknameUseCase: updateNicknameUseCase
        )
        
        let viewController = ProfileEditViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

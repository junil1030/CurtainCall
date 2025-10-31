//
//  FavoriteViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FavoriteViewController: BaseViewController {
    
    // MARK: - Properties
    private let favoriteView = FavoriteView()
    private let viewModel: FavoriteViewModel
    private let disposeBag = DisposeBag()
    private let container = DIContainer.shared
    
    // viewWillAppear 트리거를 위한 Subject
    private let viewWillAppearSubject = PublishSubject<Void>()
    
    // MARK: - Init
    init(viewModel: FavoriteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        view = favoriteView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 화면이 다시 나타날 때마다 데이터 새로고침
        viewWillAppearSubject.onNext(())
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.title = "찜한 공연"
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = FavoriteViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            sortButtonTapped: favoriteView.sortButtonTapped,
            genreButtonTapped: favoriteView.genreButtonTapped,
            areaButtonTapped: favoriteView.areaButtonTapped,
            favoriteButtonTapped: favoriteView.favoriteButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        // 찜한 공연 리스트와 빈 상태 함께 처리
        Driver.combineLatest(output.favoritesList, output.isEmpty)
            .drive(with: self) { owner, data in
                let (favorites, isEmpty) = data
                owner.favoriteView.updateFavorites(favorites, isEmpty: isEmpty)
            }
            .disposed(by: disposeBag)
        
        // 통계 정보와 월별 개수 함께 처리
        Driver.combineLatest(output.statistics, output.monthlyCount)
            .drive(with: self) { owner, data in
                let (statistics, monthlyCount) = data
                owner.favoriteView.updateStatistics(
                    totalCount: statistics.totalCount,
                    monthlyCount: monthlyCount
                )
            }
            .disposed(by: disposeBag)
        
        // 찜 해제 완료 시그널
        output.favoriteRemoved
            .emit(with: self) { owner, performanceID in
                print("찜 해제 완료: \(performanceID)")
            }
            .disposed(by: disposeBag)
        
        // 카드 탭 - 상세 화면 이동
        favoriteView.selectedCard
            .bind(with: self) { owner, cardItem in
                owner.navigateToDetailView(with: cardItem)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Navigation
extension FavoriteViewController {
    private func navigateToDetailView(with item: CardItem) {
        let viewModel = DIContainer.shared.makeDetailViewModel(performanceID: item.id)
        let viewController = DetailViewController(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }

}

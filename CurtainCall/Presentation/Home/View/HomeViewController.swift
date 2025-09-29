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
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let searchButton = UIBarButtonItem(
        image: UIImage(systemName: "magnifyingglass"),
        style: .plain,
        target: nil,
        action: nil
    )
    
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
            filterState: homeView.filterState
        )
        
        let output = viewModel.transform(input: input)
        
        output.boxOfficeList
            .drive(with: self) { owner, list in
                owner.homeView.updateBoxOfficeList(list)
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
            .subscribe(with: self) { owner, cardItem in
                print("선택된 카드: \(cardItem.title)")
                print("공연 ID: \(cardItem.id)")
                // 여기서 상세화면으로 이동하거나 다른 처리
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
        navigationItem.rightBarButtonItem = searchButton
    }
}

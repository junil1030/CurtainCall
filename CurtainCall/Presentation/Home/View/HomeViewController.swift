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
    
    override func loadView() {
        super.loadView()
        
        view = homeView
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = HomeViewModel.Input(
            selectedCard: homeView.selectedCard,
            selectedCategory: homeView.selectedCategory
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
    }
}

//
//  DetailViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa

final class DetailViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: DetailViewModel
    private let detailView = DetailView()
    private let disposeBag = DisposeBag()
    private let container = DIContainer.shared
    
    // MARK: - UI Components
    private let favoriteButton = FavoriteButton()
    
    private lazy var favoriteBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(customView: favoriteButton)
        return button
    }()
    
    // MARK: - Init
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        view = detailView
    }
    
    override func setupLayout() {
        super.setupLayout()
    }
    
    override func setupStyle() {
        super.setupStyle()
        setupNavigationBar()
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = DetailViewModel.Input(
            favoriteButtonTapped: favoriteButton.tapEvent,
            recordButtonTapped: detailView.recordButtonTapped,
            bookingSiteTapped: detailView.bookingSiteTapped
        )
        
        let output = viewModel.transform(input: input)
        
        // 상세 정보 바인딩
        output.performanceDetail
            .drive(with: self) { owner, detail in
                owner.detailView.configure(with: detail)
                owner.navigationItem.title = detail.title
            }
            .disposed(by: disposeBag)
        
        // 찜하기 상태 바인딩
        output.isFavorite
            .drive(with: self) { owner, isFavorite in
                owner.favoriteButton.setFavorite(isFavorite)
            }
            .disposed(by: disposeBag)
        
        // 로딩 상태
        output.isLoading
            .drive(with: self) { owner, isLoading in
                // TODO: 로딩 인디케이터 표시/숨김
                print("로딩 상태: \(isLoading)")
            }
            .disposed(by: disposeBag)
        
        // Safari 열기
        output.openSafari
            .emit(with: self) { owner, url in
                owner.openSafari(url: url)
            }
            .disposed(by: disposeBag)
        
        output.pushRecord
            .emit(with: self) { owner, detail in
                owner.navigateToWriteRecord(mode: .create(performanceDetail: detail))
            }
            .disposed(by: disposeBag)
        
        // 에러 처리
        output.error
            .emit(with: self) { owner, error in
                print("Error: \(error.localizedDescription)")
                // TODO: 에러 알럿 표시
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = favoriteBarButton
    }
    
    private func openSafari(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .pageSheet
        present(safariViewController, animated: true)
    }
}

// MARK: - Navigation
extension DetailViewController {
    private func navigateToWriteRecord(mode: WriteRecordMode) {
        let viewModel = container.makeWriteRecordViewModel(mode: mode)
        let viewController = WriteRecordViewController(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

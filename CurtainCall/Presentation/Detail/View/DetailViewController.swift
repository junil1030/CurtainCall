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
        setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreNavigationBar()
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
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        // 투명한 appearance 생성
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.backgroundImage = UIImage()
    
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .white
        navigationBar.backgroundColor = .clear
        
        // 좋아요 버튼
        navigationItem.rightBarButtonItem = favoriteBarButton
    }
    
    private func restoreNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        // 기본 appearance로 복원
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ccBackground
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        
        navigationBar.tintColor = .ccNavigationTint
        navigationBar.backgroundColor = .ccBackground
    }
    
    private func openSafari(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .pageSheet
        present(safariViewController, animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

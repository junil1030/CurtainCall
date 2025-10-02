//
//  FavoriteViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift

final class FavoriteViewController: BaseViewController {
    
    // MARK: - Properties
    private let favoriteView = FavoriteView()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = favoriteView
    }
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
   required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.title = "찜한 공연"
    }
    
    override func setupBind() {
        super.setupBind()
        
        // 정렬 필터
        favoriteView.sortType
            .subscribe(onNext: { sortType in
                print("정렬 변경: \(sortType.rawValue)")
                // TODO: 정렬 로직 구현
            })
            .disposed(by: disposeBag)
        
        // 장르 필터
        favoriteView.selectedGenre
            .subscribe(onNext: { genre in
                if let genre = genre {
                    print("장르 선택: \(genre.displayName)")
                } else {
                    print("전체 장르 선택")
                }
                // TODO: 장르 필터링 로직 구현
            })
            .disposed(by: disposeBag)
        
        // 지역 필터
        favoriteView.selectedArea
            .subscribe(onNext: { area in
                if let area = area {
                    print("지역 선택: \(area.displayName)")
                } else {
                    print("전체 지역 선택")
                }
                // TODO: 지역 필터링 로직 구현
            })
            .disposed(by: disposeBag)
        
        // 편집 버튼
        favoriteView.editButtonTapped
            .bind(with: self) { owner, _ in
                print("편집 버튼 탭")
            }
            .disposed(by: disposeBag)
    }
}

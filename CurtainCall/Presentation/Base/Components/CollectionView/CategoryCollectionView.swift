//
//  CategoryCollectionView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/26/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CategoryCollectionView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.contentInsetAdjustmentBehavior = .never
        return cv
    }()
    
    // MARK: - Observables
    private let categoriesRelay = BehaviorRelay<[CategoryCode]>(value: CategoryCode.allCases)
    private let selectedCategoryRelay = BehaviorRelay<CategoryCode?>(value: CategoryCode.allCases.first)
    
    // MARK: - Public Observables
    var selectedCategory: Observable<CategoryCode?> {
        return selectedCategoryRelay.asObservable()
    }
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(collectionView)
    }
    
    override func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .clear
        setupCollectionView()
        bindCollectionView()
    }
    
    // MARK: - Setup Methods
    private func setupCollectionView() {
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        collectionView.delegate = self
    }
    
    private func bindCollectionView() {
        // 1. 데이터 바인딩 (전체 데이터)
        categoriesRelay
            .bind(to: collectionView.rx.items(
                cellIdentifier: CategoryCell.identifier,
                cellType: CategoryCell.self
            )) { [weak self] index, category, cell in
                guard let self = self else { return }
                let isSelected = self.selectedCategoryRelay.value == category
                cell.configure(with: category, isSelected: isSelected)
            }
            .disposed(by: disposeBag)
        
        // 2. 선택 상태 변경 시 해당 셀들만 업데이트
        selectedCategoryRelay
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.updateVisibleCells()
            })
            .disposed(by: disposeBag)
        
        // 3. 셀 선택 처리
        collectionView.rx.itemSelected
            .withLatestFrom(categoriesRelay) { indexPath, categories in
                return categories[indexPath.row]
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, selectedCategory in
                owner.handleCategorySelection(selectedCategory)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateVisibleCells() {
        collectionView.visibleCells.forEach { cell in
            guard let categoryCell = cell as? CategoryCell,
                  let indexPath = collectionView.indexPath(for: cell) else { return }
            
            let category = categoriesRelay.value[indexPath.row]
            let isSelected = selectedCategoryRelay.value == category
            categoryCell.configure(with: category, isSelected: isSelected)
        }
    }
    
    private func handleCategorySelection(_ category: CategoryCode) {
        selectedCategoryRelay.accept(category)
    }
    
    // MARK: - Public Methods
    func selectCategory(_ category: CategoryCode?) {
        selectedCategoryRelay.accept(category)
    }
    
    func resetSelection() {
        selectedCategoryRelay.accept(nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CategoryCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = categoriesRelay.value[indexPath.row]
        let text = category.displayName
        
        // 텍스트 크기 계산
        let font = UIFont.appCallout
        let textSize = text.size(withAttributes: [.font: font])
        let width = textSize.width + 24 // 좌우 패딩
        
        return CGSize(width: max(width, 60), height: 36)
    }
}

//
//  CardCollectionView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CardCollectionView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Componenets
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = true
        cv.alwaysBounceVertical = false
        cv.alwaysBounceHorizontal = true
        cv.decelerationRate = .fast
        return cv
    }()
    
    // MARK: - Diffable DataSource
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, CardItem> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, CardItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CardCell.identifier,
                for: indexPath
            ) as! CardCell
            
            cell.configure(with: item)
            
            return cell
        }
        return dataSource
    }()
    
    // MARK: - Section
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - Observables
    private let cardDataRelay = BehaviorRelay<[CardItem]>(value: [])
    
    // MARK: - Public Observables
    var selectedCard: Observable<CardItem> {
        return collectionView.rx.itemSelected
            .withUnretained(self)
            .compactMap { (owner, indexpath) in
                return owner.cardDataRelay.value[indexpath.row]
            }
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
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.identifier)
        collectionView.delegate = self
    }
    
    private func bindCollectionView() {
        cardDataRelay
            .subscribe(with: self) { owner, cardData in
                owner.updateSnapshot(with: cardData)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Compositional Layout
     private func createLayout() -> UICollectionViewLayout {
         let itemSize = NSCollectionLayoutSize(
             widthDimension: .absolute(250),
             heightDimension: .absolute(380)
         )
         let item = NSCollectionLayoutItem(layoutSize: itemSize)
         
         let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(250),
            heightDimension: .absolute(380)
         )
         let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
         
         let section = NSCollectionLayoutSection(group: group)
         section.orthogonalScrollingBehavior = .continuous
         section.interGroupSpacing = 16
         section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
         
         return UICollectionViewCompositionalLayout(section: section)
     }
    
    // MARK: - Data Update
    private func updateSnapshot(with cardData: [CardItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CardItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cardData, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Public Methods
    func updateCards(with data: [CardItem]) {
        cardDataRelay.accept(data)
    }
}

// MARK: - UICollectionViewDelegate
extension CardCollectionView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 추후 transform 애니메이션 구현 예정
        // TODO: 중앙 카드 크게, 양옆 카드 작게 하는 애니메이션
    }
}

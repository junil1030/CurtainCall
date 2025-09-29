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
         
         let screenWidth = UIScreen.main.bounds.width
         
         let cardWidth = screenWidth * 0.65
         let posterHeight = cardWidth * (4.0 / 3.0)
         let textAreaHeight: CGFloat = 60
         let cardHeight = posterHeight + textAreaHeight
         
         let itemSize = NSCollectionLayoutSize(
             widthDimension: .absolute(cardWidth),
             heightDimension: .absolute(cardHeight)
         )
         let item = NSCollectionLayoutItem(layoutSize: itemSize)
         
         let groupSize = NSCollectionLayoutSize(
             widthDimension: .absolute(cardWidth),
             heightDimension: .absolute(cardHeight)
         )
         let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
         
         let section = NSCollectionLayoutSection(group: group)
         section.orthogonalScrollingBehavior = .groupPaging
         section.interGroupSpacing = 16
         
         let sideSpacing = (screenWidth - cardWidth) / 2
         section.contentInsets = NSDirectionalEdgeInsets(
             top: 0,
             leading: sideSpacing,
             bottom: 0,
             trailing: sideSpacing
         )
         
         section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
             guard let _ = self else { return }
             
             let containerWidth = environment.container.contentSize.width
             let centerX = offset.x + containerWidth / 2
             
             visibleItems.forEach { item in
                 let itemCenterX = item.frame.midX
                 let distance = abs(itemCenterX - centerX)
                 
                 // 거리에 따라 스케일 계산 (0.85 ~ 1.0)
                 let normalizedDistance = min(distance / (cardWidth + 16), 1.0)
                 let scale = 1.0 - (normalizedDistance * 0.15)
                 
                 // transform 적용
                 let transform = CGAffineTransform(scaleX: scale, y: scale)
                 item.transform = transform
             }
         }
         
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

    func scrollToFirst() {
        guard !cardDataRelay.value.isEmpty else { return }
        
        let firstIndexPath = IndexPath(item: 0, section: 0)
        
        Task { @MainActor in
            self.collectionView.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

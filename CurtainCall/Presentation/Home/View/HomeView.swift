//
//  HomeView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit
import SnapKit
import RxSwift
//import RxCocoa

final class HomeView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Subject
    private let selectedCategorySubject = PublishSubject<CategoryCode?>()
    private let filterStateSubject = PublishSubject<FilterButtonContainer.FilterState>()
    private let favoriteButtonTappedSubject = PublishSubject<String>()
    
    // MARK: - Observables
    var selectedCard: Observable<CardItem> {
        return collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath in
                guard let self = self,
                      case .boxOffice(let cardItem) = self.dataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }
                return cardItem
            }
    }
    
    var selectedCategory: Observable<CategoryCode?> {
        return selectedCategorySubject.asObservable()
    }
    
    var filterState: Observable<FilterButtonContainer.FilterState> {
        return filterStateSubject.asObservable()
    }
    
    var favoriteButtonTapped: Observable<String> {
        return favoriteButtonTappedSubject.asObservable()
    }
    
    // MARK: - UI Components
     private lazy var collectionView: UICollectionView = {
         let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
         cv.backgroundColor = .ccBackground
         cv.showsVerticalScrollIndicator = false
         return cv
     }()
    
    // MARK: - DataSource
    private lazy var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem> = {
        let dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
            case .greeting:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: GreetingBannerCell.identifier,
                    for: indexPath
                ) as! GreetingBannerCell
                return cell
                
            case .category:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CategoryCollectionCell.identifier,
                    for: indexPath
                ) as! CategoryCollectionCell
                
                cell.selectedCategory
                    .bind(to: self.selectedCategorySubject)
                    .disposed(by: self.disposeBag)
                
                return cell
                
            case .filter:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: FilterButtonCell.identifier,
                    for: indexPath
                ) as! FilterButtonCell
                
                cell.filterState
                    .bind(to: self.filterStateSubject)
                    .disposed(by: self.disposeBag)
                
                return cell
                
            case .boxOffice(let cardItem):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CardCell.identifier,
                    for: indexPath
                ) as! CardCell
                cell.delegate = self
                cell.configure(with: cardItem)
                return cell
            }
        }
        
        return dataSource
    }()
    
    override func setupHierarchy() {
        super.setupHierarchy()
        addSubview(collectionView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        setupCollectionView()
        applyInitialSnapshot()
    }
    
    // MARK: - Setup Methods
    private func setupCollectionView() {
        collectionView.register(GreetingBannerCell.self, forCellWithReuseIdentifier: GreetingBannerCell.identifier)
        collectionView.register(CategoryCollectionCell.self, forCellWithReuseIdentifier: CategoryCollectionCell.identifier)
        collectionView.register(FilterButtonCell.self, forCellWithReuseIdentifier: FilterButtonCell.identifier)
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.identifier)
    }
    
    // MARK: - Layout
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let section = HomeSection(rawValue: sectionIndex) else {
                return self?.createBoxOfficeSection()
            }
            
            switch section {
            case .greeting:
                return self?.createGreetingSection()
            case .category:
                return self?.createCategorySection()
            case .filter:
                return self?.createFilterSection()
            case .boxOffice:
                return self?.createBoxOfficeSection()
            }
        }
    }
    
    private func createGreetingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)
        
        return section
    }
    
    private func createCategorySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)
        
        return section
    }
    
    private func createFilterSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)
        
        return section
    }
    
    private func createBoxOfficeSection() -> NSCollectionLayoutSection {
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
        
        section.visibleItemsInvalidationHandler = { visibleItems, offset, environment in
            let containerWidth = environment.container.contentSize.width
            let centerX = offset.x + containerWidth / 2
            
            visibleItems.forEach { item in
                let itemCenterX = item.frame.midX
                let distance = abs(itemCenterX - centerX)
                
                let normalizedDistance = min(distance / (cardWidth + 16), 1.0)
                let scale = 1.0 - (normalizedDistance * 0.15)
                
                let transform = CGAffineTransform(scaleX: scale, y: scale)
                item.transform = transform
            }
        }
        
        return section
    }
    
    // MARK: - Snapshot
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
        
        // 섹션 추가
        snapshot.appendSections([.greeting, .category, .filter, .boxOffice])
        
        // 각 섹션에 아이템 추가
        snapshot.appendItems([.greeting], toSection: .greeting)
        snapshot.appendItems([.category], toSection: .category)
        snapshot.appendItems([.filter], toSection: .filter)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Public Methods
    func updateBoxOfficeList(_ boxOffices: [BoxOffice]) {
        let cardItems = boxOffices.map { $0.toCardItem() }
        
        var snapshot = dataSource.snapshot()
        
        // 기존 박스오피스 아이템 제거
        let currentBoxOfficeItems = snapshot.itemIdentifiers(inSection: .boxOffice)
        snapshot.deleteItems(currentBoxOfficeItems)
        
        // 새로운 아이템 추가
        let newItems = cardItems.map { HomeItem.boxOffice($0) }
        snapshot.appendItems(newItems, toSection: .boxOffice)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func scrollToFirstCard() {
        guard let firstBoxOfficeIndexPath = dataSource.indexPath(for: dataSource.snapshot().itemIdentifiers(inSection: .boxOffice).first ?? .greeting) else {
            return
        }
        
        collectionView.scrollToItem(at: firstBoxOfficeIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    // 좋아요 상태 업데이트 메서드 추가
    func updateFavoriteStatus(performanceID: String, isFavorite: Bool) {
        guard let indexPath = dataSource.indexPath(for: .boxOffice(CardItem(
            id: performanceID,
            imageURL: "",
            title: "",
            subtitle: "",
            badge: "",
            isFavorite: false
        ))) else { return }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CardCell {
            cell.updateFavoriteStatus(isFavorite)
        }
    }
}

extension HomeView: CardCellDelegate {
    func cardCell(_ cell: CardCell, didTapFavoriteButton performanceID: String) {
        favoriteButtonTappedSubject.onNext(performanceID)
    }
}

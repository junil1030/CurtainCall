//
//  FavoriteView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import SnapKit

final class FavoriteView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Subjects
    private let favoriteButtonTappedSubject = PublishSubject<String>()
    
    // MARK: - UI Components
    private let headerView = FavoriteHeaderView()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .ccBackground
        cv.showsVerticalScrollIndicator = true
        return cv
    }()

    private let emptyStateView = EmptyStateView()
    
    // MARK: - DataSource
    private lazy var dataSource: UICollectionViewDiffableDataSource<FavoriteSection, FavoriteItem> = {
        let dataSource = UICollectionViewDiffableDataSource<FavoriteSection, FavoriteItem>(
            collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
                
                switch item {
                case .favorite(let cardItem):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: FavoriteCardCell.identifier,
                        for: indexPath
                    ) as! FavoriteCardCell
                    cell.delegate = self
                    cell.configure(with: cardItem)
                    return cell
                }
        }
        
        return dataSource
    }()
    
    // MARK: - Public Observables
    var sortButtonTapped: Observable<FavoriteHeaderView.SortType> {
        return headerView.sortButtonTapped
    }
    
    var genreButtonTapped: Observable<GenreCode?> {
        return headerView.genreButtonTapped
    }
    
    var areaButtonTapped: Observable<AreaCode?> {
        return headerView.areaButtonTapped
    }
    
    var favoriteButtonTapped: Observable<String> {
        return favoriteButtonTappedSubject.asObservable()
    }
    
    var selectedCard: Observable<CardItem> {
        return collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath in
                guard let self = self,
                      case .favorite(let cardItem) = self.dataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }
                return cardItem
            }
    }
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(headerView)
        addSubview(collectionView)
        collectionView.addSubview(emptyStateView)
    }
    
    override func setupLayout() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(60)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
        setupCollectionView()
        setupEmptyStateView()
        applyInitialSnapshot()
    }
    
    // MARK: - Setup Methods
    private func setupEmptyStateView() {
        emptyStateView.configure(
            icon: UIImage(systemName: "heart"),
            message: "좋아하는 공연을 찜해보세요!"
        )
        emptyStateView.isHidden = true
    }

    // MARK: - Public Methods
    func updateFavorites(_ favorites: [CardItem], isEmpty: Bool) {
        var snapshot = dataSource.snapshot()
        
        // 카드 섹션의 기존 아이템 제거
        let currentItems = snapshot.itemIdentifiers(inSection: .cards)
        snapshot.deleteItems(currentItems)
        
        // 새로운 아이템 추가
        let items = favorites.map { FavoriteItem.favorite($0) }
        snapshot.appendItems(items, toSection: .cards)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
        emptyStateView.isHidden = !isEmpty
    }
    
    func updateStatistics(totalCount: Int, monthlyCount: Int) {
        headerView.configure(totalCount: totalCount, monthlyCount: monthlyCount)
    }
}

// MARK: - FavoriteCardCellDelegate
extension FavoriteView: FavoriteCardCellDelegate {
    func favoriteCardCell(_ cell: FavoriteCardCell, didTapFavoriteButton performanceID: String) {
        favoriteButtonTappedSubject.onNext(performanceID)
    }
}

// MARK: -  Base Layout & Base SnapShot
extension FavoriteView {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let section = FavoriteSection(rawValue: sectionIndex) else {
                return nil
            }
            
            switch section {
            case .cards:
                return self.createCardsSection()
            }
        }
        return layout
    }

    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<FavoriteSection, FavoriteItem>()
        snapshot.appendSections([.cards])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Register Cell
extension FavoriteView {
    private func setupCollectionView() {
        collectionView.register(FavoriteCardCell.self, forCellWithReuseIdentifier: FavoriteCardCell.identifier)
    }
}

// MARK: - Section
extension FavoriteView {
    private func createCardsSection() -> NSCollectionLayoutSection {
        let screenWidth = UIScreen.main.bounds.width
        
        // 2열 그리드
        let itemWidth = (screenWidth - 48) / 2
        let posterHeight = itemWidth * (4.0 / 3.0)
        let textAreaHeight: CGFloat = 60
        let itemHeight = posterHeight + textAreaHeight
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .absolute(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(itemHeight)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 20,
            bottom: 44,
            trailing: 20
        )
        
        return section
    }
}

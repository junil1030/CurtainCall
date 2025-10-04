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
    private let sortButtonTappedSubject = PublishSubject<FavoriteFilterCell.SortType>()
    private let genreButtonTappedSubject = PublishSubject<GenreCode?>()
    private let areaButtonTappedSubject = PublishSubject<AreaCode?>()
    private let favoriteButtonTappedSubject = PublishSubject<String>()
    
    // MARK: - UI Components
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
                case .filter:
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: FavoriteFilterCell.identifier,
                        for: indexPath
                    ) as! FavoriteFilterCell
                    
                    // 각 버튼 이벤트를 개별적으로 바인딩
                    cell.sortButtonTapped
                        .bind(to: self.sortButtonTappedSubject)
                        .disposed(by: cell.disposeBag)
                    
                    cell.genreButtonTapped
                        .bind(to: self.genreButtonTappedSubject)
                        .disposed(by: cell.disposeBag)
                    
                    cell.areaButtonTapped
                        .bind(to: self.areaButtonTappedSubject)
                        .disposed(by: cell.disposeBag)
                    
                    return cell
                    
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
        
        // 헤더 등록
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return UICollectionReusableView() }
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: FavoriteHeaderView.identifier,
                for: indexPath
            ) as! FavoriteHeaderView
            
            header.configure(totalCount: self.currentTotalCount, monthlyCount: self.currentMonthlyCount)
            
            return header
        }
        
        return dataSource
    }()
    
    // MARK: - Public Observables (개별 버튼 이벤트)
    var sortButtonTapped: Observable<FavoriteFilterCell.SortType> {
        return sortButtonTappedSubject.asObservable()
    }
    
    var genreButtonTapped: Observable<GenreCode?> {
        return genreButtonTappedSubject.asObservable()
    }
    
    var areaButtonTapped: Observable<AreaCode?> {
        return areaButtonTappedSubject.asObservable()
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
        addSubview(collectionView)
        collectionView.addSubview(emptyStateView)
    }
    
    override func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
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
        // 헤더 업데이트를 위한 스냅샷 재적용
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.filter])
        
        // supplementaryViewProvider에서 사용할 데이터 저장
        currentTotalCount = totalCount
        currentMonthlyCount = monthlyCount
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Private Properties (헤더 데이터 저장용)
    private var currentTotalCount: Int = 0
    private var currentMonthlyCount: Int = 0
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
            case .filter:
                return self.createFilterSection()
            case .cards:
                return self.createCardsSection()
            }
        }
        return layout
    }

    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<FavoriteSection, FavoriteItem>()
        
        // 필터 섹션
        snapshot.appendSections([.filter])
        snapshot.appendItems([.filter], toSection: .filter)
        
        // 카드 섹션
        snapshot.appendSections([.cards])
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Register Cell & HeaderView
extension FavoriteView {
    private func setupCollectionView() {
        // Cell 등록
        collectionView.register(FavoriteFilterCell.self, forCellWithReuseIdentifier: FavoriteFilterCell.identifier)
        collectionView.register(FavoriteCardCell.self, forCellWithReuseIdentifier: FavoriteCardCell.identifier)
        
        // Header 등록
        collectionView.register(
            FavoriteHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: FavoriteHeaderView.identifier
        )
    }
}

// MARK: - Section
extension FavoriteView {
    private func createFilterSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(56)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(56)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 20,
            bottom: 16,
            trailing: 20
        )
        
        // 헤더 추가
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
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
            top: 0,
            leading: 20,
            bottom: 44,
            trailing: 20
        )
        
        return section
    }
}

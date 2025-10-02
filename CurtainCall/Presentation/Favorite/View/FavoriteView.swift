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
    private let editButtonTappedSubject = PublishSubject<Void>()
    private let sortTypeSubject = PublishSubject<FavoriteFilterCell.SortType>()
    private let genreSubject = PublishSubject<GenreCode?>()
    private let areaSubject = PublishSubject<AreaCode?>()
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .ccBackground
        cv.showsVerticalScrollIndicator = true
        return cv
    }()
    
    private let editButton: UIButton = {
        var configure = UIButton.Configuration.plain()
        configure.image = UIImage(systemName: "pencil.line")
        configure.title = "편집"
        configure.baseForegroundColor = .ccButtonText
        let button = UIButton(configuration: configure)
        button.titleLabel?.font = .ccHeadlineBold
        button.layer.cornerRadius = 12
        button.backgroundColor = .ccPrimary
        return button
    }()
    
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
                    
                    // 필터 이벤트 바인딩
                    cell.sortType
                        .bind(to: self.sortTypeSubject)
                        .disposed(by: cell.disposeBag)
                    
                    cell.selectedGenre
                        .bind(to: self.genreSubject)
                        .disposed(by: cell.disposeBag)
                    
                    cell.selectedArea
                        .bind(to: self.areaSubject)
                        .disposed(by: cell.disposeBag)
                    
                    return cell
                    
                case .favorite(let cardItem):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: FavoriteCardCell.identifier,
                        for: indexPath
                    ) as! FavoriteCardCell
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
            
            // TODO: 추후 실제 데이터로 변경
            header.configure(totalCount: 5, monthlyCount: 2)
            
            return header
        }
        
        return dataSource
    }()
    
    // MARK: - Observables
    var editButtonTapped: Observable<Void> {
        return editButtonTappedSubject.asObservable()
    }
    
    var sortType: Observable<FavoriteFilterCell.SortType> {
        return sortTypeSubject.asObservable()
    }
    
    var selectedGenre: Observable<GenreCode?> {
        return genreSubject.asObservable()
    }
    
    var selectedArea: Observable<AreaCode?> {
        return areaSubject.asObservable()
    }
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(collectionView)
        addSubview(editButton)
    }
    
    override func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        editButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(16)
            make.height.equalTo(44)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
        setupCollectionView()
        applyInitialSnapshot()
        bindActions()
    }
    
    // MARK: - Private Methods
    private func bindActions() {
        editButton.rx.tap
            .bind(to: editButtonTappedSubject)
            .disposed(by: disposeBag)
    }

    // MARK: - Public Methods
    func updateFavorites(_ favorites: [CardItem]) {
        var snapshot = dataSource.snapshot()
        
        // 카드 섹션의 기존 아이템 제거
        let currentItems = snapshot.itemIdentifiers(inSection: .cards)
        snapshot.deleteItems(currentItems)
        
        // 새로운 아이템 추가
        let items = favorites.map { FavoriteItem.favorite($0) }
        snapshot.appendItems(items, toSection: .cards)
        
        dataSource.apply(snapshot, animatingDifferences: true)
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
        
        // TODO: 더미 데이터 (추후 실제 데이터로 변경)
        let dummyCards = (1...5).map { index in
            CardItem(
                id: "\(index)",
                imageURL: "",
                title: "공연 \(index)",
                subtitle: "공연장 \(index)",
                badge: nil,
                isFavorite: true
            )
        }
        
        let items = dummyCards.map { FavoriteItem.favorite($0) }
        snapshot.appendItems(items, toSection: .cards)
        
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

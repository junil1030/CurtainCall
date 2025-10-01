//
//  SearchView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SearchView: BaseView {
    
    // MARK: - Properties
    private let disposebag = DisposeBag()
    private var currentKeyword: String = ""
    
    // MARK: - UI Components
    private let searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "공연명을 입력해주세요"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .ccBackground
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    // MARK: - DataSource
    private lazy var dataSource: UICollectionViewDiffableDataSource<SearchSection, SearchItem> = {
        let dataSource = UICollectionViewDiffableDataSource<SearchSection, SearchItem>(
            collectionView: collectionView) { [weak self] collectionView, indexPath, item in
                guard let self = self else { return UICollectionViewCell() }
                
                switch item {
                case .recentSearch(let recentSearch):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchCell.identifier, for: indexPath) as! RecentSearchCell
                    cell.configure(with: recentSearch)
                    
                    cell.deleteButtonTapped
                        .bind(with: self) { owner, _ in
                            owner.deleteRecentSearch(recentSearch)
                        }
                        .disposed(by: cell.disposeBag)
                    
                    return cell
                    
                case .searchResult(let searchResult):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.identifier, for: indexPath) as! SearchResultCell
                    cell.configure(with: searchResult)
                    return cell
                    
                case .empty:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptySearchCell.identifier, for: indexPath) as! EmptySearchCell
                    return cell
                    
                default:
                    return UICollectionViewCell()
                }
            }
        
        // 헤더 등록
        dataSource.supplementaryViewProvider =  { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return UICollectionReusableView() }
            
            let sections = self.dataSource.snapshot().sectionIdentifiers
            let section = sections[indexPath.section]
            
            switch section {
            case .recentSearch:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecentSearchHeaderView.identifier, for: indexPath) as! RecentSearchHeaderView
                
                header.deleteAllTapped
                    .bind(with: self) { owner, _ in
                        owner.deleteAllRecentSearches()
                    }
                    .disposed(by: header.disposeBag)
                
                return header
                
            case .searchResult:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SearchResultHeaderView.identifier, for: indexPath) as! SearchResultHeaderView
                
                let snapshot = self.dataSource.snapshot()
                let resultCount = snapshot.itemIdentifiers(inSection: .searchResult).count
                header.configure(keyword: self.currentKeyword, count: resultCount)
                
                return header
                
            default:
                return UICollectionReusableView()
            }
        }
        
        return dataSource
    }()
    
    // MARK: - Observables
    var searchButtonTapped: Observable<String?> {
        return searchBar.rx.searchButtonClicked
            .map { [weak searchBar] in searchBar?.text }
    }

    // MARK: - BaseView Override Emthods
    override func setupHierarchy() {
        addSubview(searchBar)
        addSubview(collectionView)
    }
    
    override func setupLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .ccBackground
        setupCollectionView()
        applyInitialSnapshot()
    }
    
    // MARK: - Public Methods
    func updateSearchResults(results: [SearchResult]) {
        currentKeyword = searchBar.text ?? ""
        
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>()
        
        // 기존 섹션 제거
        if dataSource.snapshot().sectionIdentifiers.contains(.recentSearch) {
            var currentSnapshot = dataSource.snapshot()
            currentSnapshot.deleteSections([.recentSearch, .empty])
            dataSource.apply(currentSnapshot, animatingDifferences: false)
        }
        
        // 검색 결과 섹션 추가
        snapshot.appendSections([.searchResult])
        let items = results.map { SearchItem.searchResult($0) }
        snapshot.appendItems(items, toSection: .searchResult)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Private Methods
    private func deleteRecentSearch(_ recentSearch: RecentSearch) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([.recentSearch(recentSearch)])
        
        // 최근 검색어가 모두 삭제되면 섹션 자체를 삭제하고 empty 섹션 표시
        let remainingItems = snapshot.itemIdentifiers(inSection: .recentSearch)
        if remainingItems.isEmpty {
            snapshot.deleteSections([.recentSearch])
            dataSource.apply(snapshot, animatingDifferences: true)
            showEmptySection()
        } else {
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func deleteAllRecentSearches() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteSections([.recentSearch])
        dataSource.apply(snapshot, animatingDifferences: true)
        
        // empty 섹션 표시
        showEmptySection()
    }
    
    private func showEmptySection() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.empty])
        snapshot.appendItems([.empty], toSection: .empty)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: -  Base Layout & Base SnapShot
extension SearchView {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            
            let sections = self.dataSource.snapshot().sectionIdentifiers
            let section = sections[sectionIndex]
            
            switch section {
            case .recentSearch:
                return self.createRecentSearchSection()
            case .searchResult:
                return self.createSearchResultSection()
            case .empty:
                return self.createEmptySection()
            default:
                return self.createDefaultSection()
            }
        }
        return layout
    }
    
    private func createDefaultSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
}

// MARK: - Register Cell & HeaderView
extension SearchView {
    private func setupCollectionView() {
        // Cell
        collectionView.register(RecentSearchCell.self, forCellWithReuseIdentifier: RecentSearchCell.identifier)
        collectionView.register(EmptySearchCell.self, forCellWithReuseIdentifier: EmptySearchCell.identifier)
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.identifier)
        
        // HeaderView
        collectionView.register(
            RecentSearchHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RecentSearchHeaderView.identifier
        )
        collectionView.register(
            SearchResultHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchResultHeaderView.identifier
        )
    }
}

// MARK: - Section
extension SearchView {
    private func createRecentSearchSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(48)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(48)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        // 헤더 추가
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createEmptySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 100, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }

    private func createSearchResultSection() -> NSCollectionLayoutSection {
        // 화면 높이의 약 3.5개가 들어갈 수 있도록 계산
        let screenHeight = UIScreen.main.bounds.height
        let cellHeight = (screenHeight - 200) / 3.5 // 상단바 등을 고려한 대략적인 높이
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(cellHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(cellHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        // 헤더 추가
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }

}

// MARK: - SnapShot
extension SearchView {
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>()
        
        // 최근 검색어 섹션 추가 (더미 데이터)
        snapshot.appendSections([.recentSearch])
        let dummyData = [
            RecentSearch(keyword: "뮤지컬 위키드"),
            RecentSearch(keyword: "연극 햄릿"),
            RecentSearch(keyword: "뮤지컬 맘마미아")
        ]
        let items = dummyData.map { SearchItem.recentSearch($0) }
        snapshot.appendItems(items, toSection: .recentSearch)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

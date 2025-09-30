//
//  SearchView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SearchView: BaseView {
    
    // MARK: - Types
    enum Section: Int, CaseIterable {
        case recentSearch  // 최근 검색어 섹션
        case filter        // 필터 섹션 (검색 시만)
        case searchResult  // 검색 결과 섹션 (검색 시만)
    }
    
    enum Item: Hashable {
        case recentSearch(RecentSearch)
        case filter
        case searchResult(SearchResult)
        
        // Hashable 구현
        func hash(into hasher: inout Hasher) {
            switch self {
            case .recentSearch(let search):
                hasher.combine("recentSearch")
                hasher.combine(search.id)
            case .filter:
                hasher.combine("filter")
            case .searchResult(let result):
                hasher.combine("searchResult")
                hasher.combine(result.id)
            }
        }
        
        // Equatable 구현
        static func == (lhs: Item, rhs: Item) -> Bool {
            switch (lhs, rhs) {
            case (.recentSearch(let lSearch), .recentSearch(let rSearch)):
                return lSearch.id == rSearch.id
            case (.filter, .filter):
                return true
            case (.searchResult(let lResult), .searchResult(let rResult)):
                return lResult.id == rResult.id
            default:
                return false
            }
        }
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Subjects
    private let searchButtonTappedSubject = PublishSubject<String>()
    private let filterChangedSubject = PublishSubject<FilterButtonContainer.FilterState>()
    private let deleteRecentSearchSubject = PublishSubject<RecentSearch>()
    private let deleteAllSearchesSubject = PublishSubject<Void>()
    private let recentSearchTappedSubject = PublishSubject<RecentSearch>()
    
    // MARK: - Observables
    var searchButtonTapped: Observable<String> {
        return searchButtonTappedSubject.asObservable()
    }
    
    var filterChanged: Observable<FilterButtonContainer.FilterState> {
        return filterChangedSubject.asObservable()
    }
    
    var deleteRecentSearch: Observable<RecentSearch> {
        return deleteRecentSearchSubject.asObservable()
    }
    
    var deleteAllSearches: Observable<Void> {
        return deleteAllSearchesSubject.asObservable()
    }
    
    var recentSearchTapped: Observable<RecentSearch> {
        return recentSearchTappedSubject.asObservable()
    }
    
    var selectedSearchResult: Observable<SearchResult> {
        return collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath in
                guard let item = self?.dataSource.itemIdentifier(for: indexPath),
                      case .searchResult(let result) = item else {
                    return nil
                }
                return result
            }
    }
    
    // MARK: - UI Components
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "공연명, 배우, 극장 검색"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .ccBackground
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .ccBody
        label.textColor = .ccSecondaryText
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - DataSource
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
            case .recentSearch(let search):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecentSearchCell.identifier,
                    for: indexPath
                ) as! RecentSearchCell
                
                cell.configure(with: search)
                
                cell.deleteButtonTapped
                    .map { search }
                    .bind(to: self.deleteRecentSearchSubject)
                    .disposed(by: cell.disposeBag)
                
                return cell
                
            case .filter:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SearchFilterCell.identifier,
                    for: indexPath
                ) as! SearchFilterCell
                
                cell.filterState
                    .bind(to: self.filterChangedSubject)
                    .disposed(by: cell.disposeBag)
                
                return cell
                
            case .searchResult(let result):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SearchResultCell.identifier,
                    for: indexPath
                ) as! SearchResultCell
                
                cell.configure(with: result)
                return cell
            }
        }
        
        // 헤더 설정
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return nil }
            
            let section = Section(rawValue: indexPath.section)
            
            // 최근 검색어 섹션의 헤더만 표시
            if section == .recentSearch && kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: RecentSearchHeaderView.identifier,
                    for: indexPath
                ) as! RecentSearchHeaderView
                
                header.deleteAllTapped
                    .bind(to: self.deleteAllSearchesSubject)
                    .disposed(by: header.disposeBag)
                
                return header
            }
            
            return nil
        }
        
        return dataSource
    }()
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(searchBar)
        addSubview(collectionView)
        addSubview(emptyLabel)
    }
    
    override func setupLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
        setupCollectionView()
        bindSearchBar()
        applyInitialSnapshot()
    }
    
    // MARK: - Setup Methods
    private func setupCollectionView() {
        collectionView.register(RecentSearchCell.self, forCellWithReuseIdentifier: RecentSearchCell.identifier)
        collectionView.register(SearchFilterCell.self, forCellWithReuseIdentifier: SearchFilterCell.identifier)
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.identifier)
        collectionView.register(
            RecentSearchHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RecentSearchHeaderView.identifier
        )
        
        // 최근 검색어 셀 선택 시
        collectionView.rx.itemSelected
            .subscribe(with: self) { owner, indexPath in
                guard let item = owner.dataSource.itemIdentifier(for: indexPath) else { return }
                
                if case .recentSearch(let search) = item {
                    owner.searchBar.text = search.keyword
                    owner.recentSearchTappedSubject.onNext(search)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindSearchBar() {
        searchBar.rx.searchButtonClicked
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                let keyword = owner.searchBar.text ?? ""
                print("🔍 [SearchView] 검색 버튼 클릭 - 키워드: '\(keyword)'")
                owner.searchButtonTappedSubject.onNext(keyword)
                owner.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Initial Snapshot
    private func applyInitialSnapshot() {
        print("🔍 [SearchView] 초기 스냅샷 적용")
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        // 초기에는 빈 상태
        emptyLabel.text = "공연을 검색해보세요!"
        emptyLabel.isHidden = false
        collectionView.isHidden = true
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Layout
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let section = Section(rawValue: sectionIndex) else {
                return Self.createDefaultSection()
            }
            
            switch section {
            case .recentSearch:
                return Self.createRecentSearchSection()
            case .filter:
                return Self.createFilterSection()
            case .searchResult:
                return Self.createSearchResultSection()
            }
        }
    }
    
    private static func createDefaultSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }
    
    private static func createRecentSearchSection() -> NSCollectionLayoutSection {
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
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
    
    private static func createFilterSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)  // 100 → 120으로 증가
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)  // 100 → 120으로 증가
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        
        return section
    }
    
    private static func createSearchResultSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(115)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(115)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1
        
        return section
    }
    
    // MARK: - Public Methods
    func updateRecentSearches(_ searches: [RecentSearch]) {
        print("🔍 [SearchView] updateRecentSearches 호출 - \(searches.count)개")
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        if searches.isEmpty {
            // 최근 검색어가 없을 때
            print("   - 최근 검색어 없음")
            emptyLabel.text = "공연을 검색해보세요!"
            emptyLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            // 최근 검색어가 있을 때
            print("   - 최근 검색어 표시")
            emptyLabel.isHidden = true
            collectionView.isHidden = false
            
            snapshot.appendSections([.recentSearch])
            let items = searches.map { Item.recentSearch($0) }
            snapshot.appendItems(items, toSection: .recentSearch)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func updateSearchResults(_ results: [SearchResult], hasSearched: Bool) {
        print("🔍 [SearchView] updateSearchResults 호출")
        print("   - 결과 개수: \(results.count)")
        print("   - 검색 여부: \(hasSearched)")
        
        // 검색을 한 적이 없으면 아무것도 하지 않음
        guard hasSearched else {
            print("   - 검색하지 않음 - 스킵")
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        // 1. 필터 섹션 추가 (항상 첫 번째)
        snapshot.appendSections([.filter])
        snapshot.appendItems([.filter], toSection: .filter)
        print("   - 필터 섹션 추가됨")
        
        // 2. 검색 결과 섹션 추가
        snapshot.appendSections([.searchResult])
        
        if results.isEmpty {
            // 검색 결과가 없을 때
            print("   - 검색 결과 없음")
            emptyLabel.text = "검색 결과가 없어요."
            emptyLabel.isHidden = false
        } else {
            // 검색 결과가 있을 때
            print("   - 검색 결과 표시: \(results.count)개")
            emptyLabel.isHidden = true
            let items = results.map { Item.searchResult($0) }
            snapshot.appendItems(items, toSection: .searchResult)
        }
        
        collectionView.isHidden = false
        dataSource.apply(snapshot, animatingDifferences: true)
        print("   - 스냅샷 적용 완료")
    }
}

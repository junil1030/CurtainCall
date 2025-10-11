//
//  RecordListView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/10/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class RecordListView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Subjects
    private let cellTappedSubject = PublishSubject<String>()
    private let editButtonTappedSubject = PublishSubject<String>()
    
    // MARK: - UI Components
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "공연명으로 검색"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private let categoryCollectionView = CategoryCollectionView()
    
    private let filterContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let filterStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var ratingFilterButton: FilterButton = {
        let items = RatingFilterOption.allCases.map { option in
            FilterButton.DropdownItem(title: option.displayName, value: option)
        }
        let button = FilterButton(type: .dropdown(items: items), title: "평점")
        return button
    }()
    
    private lazy var sortFilterButton: FilterButton = {
        let items = RecordSortType.allCases.map { type in
            FilterButton.DropdownItem(title: type.displayName, value: type)
        }
        let button = FilterButton(type: .dropdown(items: items), title: RecordSortType.latest.displayName)
        return button
    }()
    
    private let resultCountLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccSecondaryText
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .ccBackground
        cv.showsVerticalScrollIndicator = true
        return cv
    }()
    
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.configure(
            icon: UIImage(systemName: "calendar.badge.exclamationmark"),
            message: "검색 결과가 없습니다"
        )
        view.isHidden = true
        return view
    }()
    
    // MARK: - DataSource
    private lazy var dataSource: UICollectionViewDiffableDataSource<RecordSection, RecordItem> = {
        let dataSource = UICollectionViewDiffableDataSource<RecordSection, RecordItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
            case .record(let recordDTO):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecordListCell.identifier,
                    for: indexPath
                ) as! RecordListCell
                
                cell.configure(with: recordDTO)
                
                // 편집 버튼 탭 이벤트 구독
                cell.editButtonTapped
                    .map { recordDTO.id }
                    .bind(to: self.editButtonTappedSubject)
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
        }
        
        return dataSource
    }()

    // MARK: - Observables
    var searchTextChanged: Observable<String> {
        return searchBar.rx.text.orEmpty.asObservable()
    }
    
    var categorySelected: Observable<CategoryCode?> {
        return categoryCollectionView.selectedCategory
    }
    
    var ratingFilterChanged: Observable<[RatingFilterOption]> {
        return ratingFilterButton.selectedValue
            .compactMap { $0 as? RatingFilterOption }
            .map { [$0] }
    }
    
    var sortTypeChanged: Observable<RecordSortType> {
        return sortFilterButton.selectedValue
            .compactMap { $0 as? RecordSortType }
    }
    
    var cellTapped: Observable<String> {
        return cellTappedSubject.asObservable()
    }
    
    var editButtonTapped: Observable<String> {
        return editButtonTappedSubject.asObservable()
    }
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(searchBar)
        addSubview(categoryCollectionView)
        addSubview(filterContainerView)
        addSubview(resultCountLabel)
        addSubview(collectionView)
        addSubview(emptyStateView)
        
        filterContainerView.addSubview(filterStackView)
        filterStackView.addArrangedSubview(ratingFilterButton)
        filterStackView.addArrangedSubview(sortFilterButton)
    }
    
    override func setupLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        filterContainerView.snp.makeConstraints { make in
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        filterStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        resultCountLabel.snp.makeConstraints { make in
            make.top.equalTo(filterContainerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(20)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(resultCountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.center.equalTo(collectionView)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .ccBackground
        
        setupCollectionView()
        applyInitialSnapshot()
        bindCollectionViewTap()
    }
    
    // MARK: - Setup Methods
    private func setupCollectionView() {
        collectionView.register(
            RecordListCell.self,
            forCellWithReuseIdentifier: RecordListCell.identifier
        )
    }
    
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<RecordSection, RecordItem>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func bindCollectionViewTap() {
        collectionView.rx.itemSelected
            .withLatestFrom(Observable.just(dataSource)) { indexPath, dataSource in
                return dataSource.itemIdentifier(for: indexPath)
            }
            .compactMap { item -> String? in
                guard case .record(let recordDTO) = item else { return nil }
                return recordDTO.performanceId
            }
            .bind(to: cellTappedSubject)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Methods
    func updateRecords(records: [ViewingRecordDTO]) {
        var snapshot = NSDiffableDataSourceSnapshot<RecordSection, RecordItem>()
        snapshot.appendSections([.main])
        
        let items = records.map { RecordItem.record($0) }
        snapshot.appendItems(items, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func updateFilteredCount(_ count: Int) {
        resultCountLabel.text = "총 \(count)개의 관람 기록"
    }
    
    func updateEmptyState(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
}

// MARK: - Layout
extension RecordListView {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            return self.createMainSection()
        }
        return layout
    }
    
    private func createMainSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
}

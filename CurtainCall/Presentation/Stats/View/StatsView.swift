//
//  StatsView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class StatsView: BaseView {
    
    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<StatsSection, StatsItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<StatsSection,StatsItem>
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .ccBackground
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var dataSource: DataSource = {
        createDataSource()
    }()
    
    // MARK: - Observables
    private let periodChangedSubject = PublishSubject<StatsPeriod>()
    
    var periodChanged: Observable<StatsPeriod> {
        return periodChangedSubject.asObservable()
    }
    
    // MARK: - Override Methods
    override func setupHierarchy() {
        addSubview(collectionView)
    }
    
    override func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
    }
    
    // MARK: - PublicMethods
    
    // 통계 데이터 업데이트
    func updateStats(sections: [StatsSection: [StatsItem]]) {
        var snapshot = Snapshot()
        
        // 섹션 순서대로 추가
        let orderedSections: [StatsSection] = [.summary, .trend, .genre, .companion, .area]
        
        for section in orderedSections {
            if let items = sections[section], !items.isEmpty {
                snapshot.appendSections([section])
                snapshot.appendItems(items, toSection: section)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Private Methods
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self,
                  let sectionIdentifier = self.dataSource.sectionIdentifier(for: sectionIndex) else {
                return self?.createDefaultSection()
            }
            
            switch sectionIdentifier {
            case .summary:
                return self.createSummarySection()
            case .trend:
                return self.createTrendSection()
            case .genre:
                return self.createGenreSection()
            case .companion:
                return self.createCompanionSection()
            case .area:
                return self.createAreaSection()
            }
        }
    }
    
    private func createDataSource() -> DataSource {
        let summaryCellRegistration = createSummaryCellRegistration()
        let trendCellRegistration = createTrendCellRegistration()
        let genreCellRegistration = createGenreCellRegistration()
        let companionCellRegistration = createCompanionCellRegistration()
        let areaCellRegistration = createAreaCellRegistration()
        
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .summary(let data):
                return collectionView.dequeueConfiguredReusableCell(
                    using: summaryCellRegistration,
                    for: indexPath,
                    item: data
                )
            case .trend(let data):
                return collectionView.dequeueConfiguredReusableCell(
                    using: trendCellRegistration,
                    for: indexPath,
                    item: data
                )
            case .genre(let data):
                return collectionView.dequeueConfiguredReusableCell(
                    using: genreCellRegistration,
                    for: indexPath,
                    item: data
                )
            case .companion(let data):
                return collectionView.dequeueConfiguredReusableCell(
                    using: companionCellRegistration,
                    for: indexPath,
                    item: data
                )
            case .area(let data):
                return collectionView.dequeueConfiguredReusableCell(
                    using: areaCellRegistration,
                    for: indexPath,
                    item: data
                )
            }
        }
        
        // Supplementary View Registration
        let segmentHeaderRegistration = createSegmentHeaderRegistration()
        let trendTitleRegistration = createTrendTitleRegistration()
        let genreTitleRegistration = createGenreTitleRegistration()
        let companionTitleRegistration = createCompanionTitleRegistration()
        let areaTitleRegistration = createAreaTitleRegistration()
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            // Segment Control Header
            if kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: segmentHeaderRegistration,
                    for: indexPath
                )
            }
            
            // Trend Title
            if kind == "trend-title" {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: trendTitleRegistration,
                    for: indexPath
                )
            }
            
            if kind == "genre-title" {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: genreTitleRegistration,
                    for: indexPath
                )
            }
            
            // Companion Title
            if kind == "companion-title" {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: companionTitleRegistration,
                    for: indexPath
                )
            }
            
            // Area Title
            if kind == "area-title" {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: areaTitleRegistration,
                    for: indexPath
                )
            }
            
            return nil
        }
        
        return dataSource
    }
    
    private func createSegmentHeaderRegistration() -> UICollectionView.SupplementaryRegistration<SegmentControlHeaderView> {
        return UICollectionView.SupplementaryRegistration<SegmentControlHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self = self else { return }
            
            supplementaryView.periodSelected
                .bind(to: self.periodChangedSubject)
                .disposed(by: supplementaryView.disposeBag)
        }
    }
    
    // Trend Title Registration
    private func createTrendTitleRegistration() -> UICollectionView.SupplementaryRegistration<SectionTitleView> {
        return UICollectionView.SupplementaryRegistration<SectionTitleView>(
            elementKind: "trend-title"
        ) { supplementaryView, elementKind, indexPath in
            supplementaryView.configure(
                title: "관람 트렌드",
                icon: UIImage(systemName: "chart.bar.fill")
            )
        }
    }
    
    // Genre Title Registration
    private func createGenreTitleRegistration() -> UICollectionView.SupplementaryRegistration<SectionTitleView> {
        return UICollectionView.SupplementaryRegistration<SectionTitleView>(
            elementKind: "genre-title"
        ) { supplementaryView, elementKind, indexPath in
            supplementaryView.configure(
                title: "장르별 분석",
                icon: UIImage(systemName: "chart.bar.fill")
            )
        }
    }
    
    // Companion Title Registration
    private func createCompanionTitleRegistration() -> UICollectionView.SupplementaryRegistration<SectionTitleView> {
        return UICollectionView.SupplementaryRegistration<SectionTitleView>(
            elementKind: "companion-title"
        ) { supplementaryView, elementKind, indexPath in
            supplementaryView.configure(
                title: "함께한 사람들",
                icon: UIImage(systemName: "person.2.fill")
            )
        }
    }
    
    // Area Title Registration
    private func createAreaTitleRegistration() -> UICollectionView.SupplementaryRegistration<SectionTitleView> {
        return UICollectionView.SupplementaryRegistration<SectionTitleView>(
            elementKind: "area-title"
        ) { supplementaryView, elementKind, indexPath in
            supplementaryView.configure(
                title: "주요 관람 지역",
                icon: UIImage(systemName: "map.fill")
            )
        }
    }
}

// MARK: - Layout Sections
extension StatsView {
    
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func createSummarySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(68)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.pinToVisibleBounds = true
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createTrendSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(220)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(250)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: "trend-title",
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createGenreSection() -> NSCollectionLayoutSection {
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
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: "genre-title",
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createCompanionSection() -> NSCollectionLayoutSection {
        // 2x2 그리드
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.45),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: nil,
            top: nil,
            trailing: .fixed(12),
            bottom: .fixed(12)
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 4)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: "companion-title",
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createAreaSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: "area-title",
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

// MARK: - Cell Registrations
extension StatsView {
    
    private func createSummaryCellRegistration() -> UICollectionView.CellRegistration<StatsSummaryCell, StatsSummaryItem> {
        return UICollectionView.CellRegistration<StatsSummaryCell, StatsSummaryItem> { cell, indexPath, item in
            cell.configure(with: item)
        }
    }
    
    private func createTrendCellRegistration() -> UICollectionView.CellRegistration<TrendChartCell, TrendChartItem> {
        return UICollectionView.CellRegistration<TrendChartCell, TrendChartItem> { cell, indexPath, item in
            cell.configure(with: item)
        }
    }
    
    private func createGenreCellRegistration() -> UICollectionView.CellRegistration<GenreAnalysisCell, GenreAnalysisItem> {
        return UICollectionView.CellRegistration<GenreAnalysisCell, GenreAnalysisItem> { cell, indexPath, item in
            cell.configure(with: item)
        }
    }
    
    private func createCompanionCellRegistration() -> UICollectionView.CellRegistration<CompanionCell, CompanionItem> {
        return UICollectionView.CellRegistration<CompanionCell, CompanionItem> { cell, indexPath, item in
            cell.configure(with: item)
        }
    }
    
    private func createAreaCellRegistration() -> UICollectionView.CellRegistration<AreaCell, AreaItem> {
        return UICollectionView.CellRegistration<AreaCell, AreaItem> { cell, indexPath, item in
            cell.configure(with: item)
        }
    }
}

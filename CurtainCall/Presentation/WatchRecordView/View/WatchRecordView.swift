//
//  WatchRecordView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class WatchRecordView: BaseView {
    
    // MARK: - Types
    enum Section: Hashable {
        case main
    }
    
    enum Item: Hashable {
        case performanceInfo
        case viewingInfo
        case rating
        case memo
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var performanceDetail: PerformanceDetail?
    
    // MARK: - Subjects
    private let dateButtonTappedSubject = PublishSubject<Void>()
    private let timeButtonTappedSubject = PublishSubject<Void>()
    private let companionSelectedSubject = PublishSubject<String>()
    private let seatTextChangedSubject = PublishSubject<String>()
    
    // MARK: - Observables
    var dateButtonTapped: Observable<Void> {
        return dateButtonTappedSubject.asObservable()
    }
    
    var timeButtonTapped: Observable<Void> {
        return timeButtonTappedSubject.asObservable()
    }
    
    var companionSelected: Observable<String> {
        return companionSelectedSubject.asObservable()
    }
    
    var seatTextChanged: Observable<String> {
        return seatTextChangedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .ccBackground
        cv.showsVerticalScrollIndicator = false
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    // MARK: - DataSource
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
            case .performanceInfo:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PerformanceInfoCell.identifier,
                    for: indexPath
                ) as! PerformanceInfoCell
            
                if let detail = self.performanceDetail {
                    cell.configure(with: detail)
                }
                
                return cell
                
            case .viewingInfo:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ViewingInfoInputCell.identifier,
                    for: indexPath
                ) as! ViewingInfoInputCell
                
                // 이벤트 바인딩
                cell.dateButtonTapped
                    .bind(to: self.dateButtonTappedSubject)
                    .disposed(by: cell.disposeBag)
                
                cell.timeButtonTapped
                    .bind(to: self.timeButtonTappedSubject)
                    .disposed(by: cell.disposeBag)
                
                cell.companionSelected
                    .bind(to: self.companionSelectedSubject)
                    .disposed(by: cell.disposeBag)
                
                cell.seatTextChanged
                    .bind(to: self.seatTextChangedSubject)
                    .disposed(by: cell.disposeBag)
                
                return cell
                
            case .rating:
                // TODO: 나중에 구현
                return UICollectionViewCell()
                
            case .memo:
                // TODO: 나중에 구현
                return UICollectionViewCell()
            }
        }
        
        return dataSource
    }()
    
    // MARK: - Override Methods
    override func setupHierarchy() {
        super.setupHierarchy()
        
        addSubview(collectionView)
    }
    
    override func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        setupCollectionView()
        applyInitialSnapshot()
    }
    
    // MARK: - Configure
    func configure(with detail: PerformanceDetail) {
        self.performanceDetail = detail
        
        // 스냅샷 재적용하여 셀 업데이트
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([.performanceInfo])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Private Methods
extension WatchRecordView {
    private func setupCollectionView() {
        // Cell 등록
        collectionView.register(
            PerformanceInfoCell.self,
            forCellWithReuseIdentifier: PerformanceInfoCell.identifier
        )
        collectionView.register(
            ViewingInfoInputCell.self,
            forCellWithReuseIdentifier: ViewingInfoInputCell.identifier
        )
    }
    
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.performanceInfo, .viewingInfo], toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Layout
extension WatchRecordView {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            return self.createMainSection()
        }
        return layout
    }
    
    private func createMainSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
}

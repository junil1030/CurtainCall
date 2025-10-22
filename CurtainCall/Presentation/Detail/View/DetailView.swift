//
//  DetailView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DetailView: BaseView {
    
    // MARK: - DetailItem 재정의
    enum DetailItem: Hashable {
        case poster(String)
        case tabContent(PerformanceDetail)
        case detailPoster(String)
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Subjects
    private let recordButtonTappedSubject = PublishSubject<Void>()
    private let bookingSiteTappedSubject = PublishSubject<String>()
    
    // MARK: - Observables
    var recordButtonTapped: Observable<Void> {
        return recordButtonTappedSubject.asObservable()
    }
    
    var bookingSiteTapped: Observable<String> {
        return bookingSiteTappedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .ccBackground
        cv.showsVerticalScrollIndicator = false
        cv.contentInsetAdjustmentBehavior = .automatic
        return cv
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton()
        button.setTitle("기록하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .ccHeadlineBold
        button.backgroundColor = .ccPrimary
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: - DataSource
    private lazy var dataSource: UICollectionViewDiffableDataSource<DetailSection, DetailItem> = {
        let dataSource = UICollectionViewDiffableDataSource<DetailSection, DetailItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
            case .poster(let url):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PosterCell.identifier,
                    for: indexPath
                ) as! PosterCell
                cell.configure(with: url)
                return cell
                
            case .tabContent(let detail):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DetailTabContentCell.identifier,
                    for: indexPath
                ) as! DetailTabContentCell
                cell.configure(with: detail)
                
                // 예매 버튼 탭 이벤트 전달
                cell.bookingSiteSelected
                    .bind(to: self.bookingSiteTappedSubject)
                    .disposed(by: cell.disposeBag)
                
                return cell
                
            case .detailPoster(let url):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DetailPosterCell.identifier,
                    for: indexPath
                ) as! DetailPosterCell
                cell.configure(with: url)
                return cell
            }
        }
        return dataSource
    }()
    
    override func setupHierarchy() {
        addSubview(collectionView)
        addSubview(recordButton)
    }
    
    override func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(recordButton.snp.top).offset(-8)
        }
        
        recordButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(4)
            make.height.equalTo(44)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        setupCollectionView()
        bindActions()
    }
    
    // MARK: - Setup Methods
    private func setupCollectionView() {
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.identifier)
        collectionView.register(DetailTabContentCell.self, forCellWithReuseIdentifier: DetailTabContentCell.identifier)
        collectionView.register(DetailPosterCell.self, forCellWithReuseIdentifier: DetailPosterCell.identifier)
    }
     
    private func bindActions() {
        recordButton.rx.tap
            .bind(to: recordButtonTappedSubject)
            .disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let section = DetailSection(rawValue: sectionIndex) else {
                return Self.createDefaultSection()
            }
            
            switch section {
            case .poster:
                return Self.createPosterSection()
            case .tabContent:
                return Self.createTabContentSection()
            case .detailPoster:
                return Self.createDetailPosterSection()
            }
        }
    }
    
    // MARK: - Public Methods
    func configure(with detail: PerformanceDetail) {
        var snapshot = NSDiffableDataSourceSnapshot<DetailSection, DetailItem>()
        
        // 포스터 섹션
        snapshot.appendSections([.poster])
        snapshot.appendItems([.poster(detail.posterURL ?? "")], toSection: .poster)
        
        // 탭 컨텐츠 섹션
        snapshot.appendSections([.tabContent])
        snapshot.appendItems([.tabContent(detail)], toSection: .tabContent)
        
        // 상세 포스터 섹션
        if let detailPosters = detail.detailPosterURL, !detailPosters.isEmpty {
            snapshot.appendSections([.detailPoster])
            let posterItems = detailPosters.map { DetailItem.detailPoster($0) }
            snapshot.appendItems(posterItems, toSection: .detailPoster)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Create Layout
extension DetailView {
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
    
    private static func createPosterSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(250)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(250)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }
    
    private static func createTabContentSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(230)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(230)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        return section
    }
    
    private static func createDetailPosterSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(400)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(400)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20)
        return section
    }
}

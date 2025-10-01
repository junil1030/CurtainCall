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
    
    enum DetailItem: Hashable {
        case poster(String)
        case info(InfoData)
        case bookingSite(BookingSite)
        case detailPoster(String)
    }
    
    struct InfoData: Hashable {
        let symbol: String
        let text: String
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
        cv.contentInsetAdjustmentBehavior = .never
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
                
            case .info(let data):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: InfoCell.identifier,
                    for: indexPath
                ) as! InfoCell
                cell.configure(with: data)
                return cell
                
            case .bookingSite(let site):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: BookingSiteCell.identifier,
                    for: indexPath
                ) as! BookingSiteCell
                cell.configure(with: site)
                
                cell.buttonTapped
                    .map { site.url }
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
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(recordButton.snp.top)
        }
        
        recordButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(16)
            make.height.equalTo(56)
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
         collectionView.register(InfoCell.self, forCellWithReuseIdentifier: InfoCell.identifier)
         collectionView.register(BookingSiteCell.self, forCellWithReuseIdentifier: BookingSiteCell.identifier)
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
            case .info:
                return Self.createInfoSection()
            case .bookingSite:
                return Self.createBookingSiteSection()
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
        snapshot.appendItems([.poster(detail.posterURL)], toSection: .poster)
        
        // 정보 섹션 (날짜, 장소, 캐스트)
        snapshot.appendSections([.info])
        let dateInfo: InfoData
        let locationInfo: InfoData
        
        if let startDate = detail.startDate, let endDate = detail.endDate {
            dateInfo = InfoData(symbol: "calendar", text: "\(startDate) ~ \(endDate)")
        } else {
            dateInfo = InfoData(symbol: "calendar", text: "공연 날짜에 대한 정보가 없어요")
        }
        
        if let area = detail.area, let location = detail.location {
            locationInfo = InfoData(symbol: "map", text: "\(area) > \(location)")
        } else {
            locationInfo = InfoData(symbol: "map", text: "장소에 대한 정보가 없어요")
        }
        
        let castInfo = InfoData(symbol: "person.3", text: detail.castText)
        snapshot.appendItems([.info(dateInfo), .info(locationInfo), .info(castInfo)], toSection: .info)
        
        // 예매 사이트 섹션
        if !detail.bookingSites.isEmpty {
            snapshot.appendSections([.bookingSite])
            let bookingItems = detail.bookingSites.map { DetailItem.bookingSite($0) }
            snapshot.appendItems(bookingItems, toSection: .bookingSite)
        }
        
        // 상세 포스터 섹션
        snapshot.appendSections([.detailPoster])
        // MARK: - 변경 필요
        snapshot.appendItems([.detailPoster(detail.detailPosterURL.first ?? "")], toSection: .detailPoster)
        
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
        let screenWidth = UIScreen.main.bounds.width
        let posterHeight = screenWidth * (4.0 / 3.0)
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(posterHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(posterHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private static func createInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        return section
    }
    
    private static func createBookingSiteSection() -> NSCollectionLayoutSection {
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
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 100, trailing: 20)
        return section
    }
}

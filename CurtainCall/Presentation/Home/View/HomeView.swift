//
//  HomeView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit
import SnapKit
import RxSwift
//import RxCocoa

final class HomeView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Subject
    private let selectedCategorySubject = PublishSubject<CategoryCode?>()
    private let filterStateSubject = PublishSubject<FilterButtonCell.FilterState>()
    private let searchButtonTappedSubject = PublishSubject<Void>()
    private let headerFavoriteButtonTappedSubject = PublishSubject<Void>()
    
    // MARK: - Observables
    var selectedCard: Observable<CardItem> {
        return collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath in
                guard let self = self,
                      case .boxOffice(let cardItem) = self.dataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }
                return cardItem
            }
    }
    
    var selectedCategory: Observable<CategoryCode?> {
        return selectedCategorySubject.asObservable()
    }
    
    var filterState: Observable<FilterButtonCell.FilterState> {
        return filterStateSubject.asObservable()
    }
    
    var searchButtonTapped: Observable<Void> {
        return searchButtonTappedSubject.asObservable()
    }
    
    var headerFavoriteButtonTapped: Observable<Void> {
        return headerFavoriteButtonTappedSubject.asObservable()
    }
    
    // MARK: - Header UI Components
    private let headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let curtainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "CurtainCallImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .ccPrimary
        button.backgroundColor = .white.withAlphaComponent(0.95)
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .ccPrimary
        button.backgroundColor = .white.withAlphaComponent(0.95)
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .ccTitle2Bold
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private let suggestionLabel: UILabel = {
        let label = UILabel()
        label.font = .ccTitle2Bold
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - CollectionView
     private lazy var collectionView: UICollectionView = {
         let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
         cv.backgroundColor = .clear
         cv.showsVerticalScrollIndicator = false
         cv.isScrollEnabled = false
         return cv
     }()
    
    // MARK: - DataSource
    private lazy var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem> = {
        let dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
            case .category:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CategoryCollectionCell.identifier,
                    for: indexPath
                ) as! CategoryCollectionCell
                
                cell.selectedCategory
                    .bind(to: self.selectedCategorySubject)
                    .disposed(by: self.disposeBag)
                
                return cell
                
            case .filter:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: FilterButtonCell.identifier,
                    for: indexPath
                ) as! FilterButtonCell
                
                cell.filterState
                    .bind(to: self.filterStateSubject)
                    .disposed(by: self.disposeBag)
                
                return cell
                
            case .boxOffice(let cardItem):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CardCell.identifier,
                    for: indexPath
                ) as! CardCell
                cell.configure(with: cardItem)
                return cell
            }
        }
        
        return dataSource
    }()
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        // 헤더 추가
        addSubview(headerContainerView)
        headerContainerView.addSubview(curtainImageView)
        headerContainerView.addSubview(gradientView)
        headerContainerView.addSubview(searchButton)
        headerContainerView.addSubview(favoriteButton)
        headerContainerView.addSubview(nicknameLabel)
        headerContainerView.addSubview(suggestionLabel)
        
        // collectionView 추가
        addSubview(collectionView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        let screenHeight = UIScreen.main.bounds.height
        let headerHeight = screenHeight / 5
        let containerheight = headerHeight + 50
        
        // 헤더 컨테이너 - 화면 최상단부터 104pt
        headerContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(containerheight)
        }
        
        // 커튼 이미지 - 헤더 컨테이너 전체
        curtainImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 검색 버튼 - Safe Area top 기준 우측 상단
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(40)
        }
        
        // 찜 버튼 - 검색 버튼 왼쪽
        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalTo(searchButton)
            make.trailing.equalTo(searchButton.snp.leading).offset(-8)
            make.width.height.equalTo(40)
        }
        
        // 닉네임 레이블
        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(searchButton)
            make.trailing.lessThanOrEqualTo(favoriteButton.snp.leading)
        }
        
        // 제안 레이블
        suggestionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(2)
            make.trailing.lessThanOrEqualTo(favoriteButton.snp.leading)
        }
        
        // CollectionView - 헤더 아래부터
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerContainerView.snp.bottom).offset(-30)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        setupCollectionView()
        applyInitialSnapshot()
        updateGreeting()
        bindButtons()
    }
    
    // MARK: - Setup Methods
    private func setupCollectionView() {
        collectionView.register(CategoryCollectionCell.self, forCellWithReuseIdentifier: CategoryCollectionCell.identifier)
        collectionView.register(FilterButtonCell.self, forCellWithReuseIdentifier: FilterButtonCell.identifier)
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.identifier)
    }
    
    private func bindButtons() {
        searchButton.rx.tap
            .bind(to: searchButtonTappedSubject)
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap
            .bind(to: headerFavoriteButtonTappedSubject)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Layout
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let section = HomeSection(rawValue: sectionIndex) else {
                return self?.createBoxOfficeSection()
            }
            
            switch section {
            case .category:
                return self?.createCategorySection()
            case .filter:
                return self?.createFilterSection()
            case .boxOffice:
                return self?.createBoxOfficeSection()
            }
        }
    }
    
    private func createCategorySection() -> NSCollectionLayoutSection {
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)
        
        return section
    }
    
    private func createFilterSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 4, trailing: 12)
        
        return section
    }
    
    private func createBoxOfficeSection() -> NSCollectionLayoutSection {
        let screenWidth = UIScreen.main.bounds.width
        
        // 높이 바꿔야함 날짜 잘린다  ~
        let cardWidth = screenWidth * 0.65
        let posterHeight = cardWidth * (4.0 / 3.0)
        let textAreaHeight: CGFloat = 80
        let cardHeight = posterHeight + textAreaHeight
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(cardWidth),
            heightDimension: .absolute(cardHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(cardWidth),
            heightDimension: .absolute(cardHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 16
        
        let sideSpacing = (screenWidth - cardWidth) / 2
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: sideSpacing,
            bottom: 0,
            trailing: sideSpacing
        )
        
        section.visibleItemsInvalidationHandler = { visibleItems, offset, environment in
            let containerWidth = environment.container.contentSize.width
            let centerX = offset.x + containerWidth / 2
            
            visibleItems.forEach { item in
                let itemCenterX = item.frame.midX
                let distance = abs(itemCenterX - centerX)
                
                let normalizedDistance = min(distance / (cardWidth + 16), 1.0)
                let scale = 1.0 - (normalizedDistance * 0.15)
                
                let transform = CGAffineTransform(scaleX: scale, y: scale)
                item.transform = transform
            }
        }
        
        return section
    }
    
    // MARK: - Snapshot
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
        
        // 섹션 추가
        snapshot.appendSections([.category, .filter, .boxOffice])
        
        // 각 섹션에 아이템 추가
        snapshot.appendItems([.category], toSection: .category)
        snapshot.appendItems([.filter], toSection: .filter)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Greeting Methods
    private func updateGreeting() {
        let timeOfDay = getCurrentTimeOfDay()
        
        // 랜덤 제안 문구 선택
        let suggestion = timeOfDay.suggestions.randomElement() ?? "오늘은 어떤 공연을 볼까요?"
        suggestionLabel.text = suggestion
    }
    
    private func getCurrentTimeOfDay() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<12:
            return .morning
        case 12..<14:
            return .lunch
        case 14..<18:
            return .afternoon
        case 18..<23:
            return .evening
        default:
            return .lateNight
        }
    }
    
    // MARK: - Public Methods
    func updateGreetingText(nickname: String) {
        nicknameLabel.text = "\(nickname)님!"
        updateGreeting()
    }
    
    func updateCardItems(_ cardItems: [CardItem]) {
        var snapshot = dataSource.snapshot()
        
        let currentBoxOfficeItems = snapshot.itemIdentifiers(inSection: .boxOffice)
        snapshot.deleteItems(currentBoxOfficeItems)
        
        let newItems = cardItems.map { HomeItem.boxOffice($0) }
        snapshot.appendItems(newItems, toSection: .boxOffice)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 현재 화면에 보이는 IndexPath들
            let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems
            
            for indexPath in visibleIndexPaths {
                // boxOffice 섹션만 처리
                guard let item = self.dataSource.itemIdentifier(for: indexPath),
                      case .boxOffice(let cardItem) = item,
                      let cell = self.collectionView.cellForItem(at: indexPath) as? CardCell else {
                    continue
                }
                
                // 셀 강제 업데이트
                cell.configure(with: cardItem)
            }
        }
    }
    
    func scrollToFirstCard() {
        guard let firstBoxOfficeIndexPath = dataSource.indexPath(for: dataSource.snapshot().itemIdentifiers(inSection: .boxOffice).first ?? .category) else {
            return
        }
        
        collectionView.scrollToItem(at: firstBoxOfficeIndexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - TimeOfDay
extension HomeView {
    private enum TimeOfDay {
        case morning
        case lunch
        case afternoon
        case evening
        case lateNight
        
        var suggestions: [String] {
            switch self {
            case .morning:
                return ["오늘은 어떤 공연을 만나볼까요?", "아침부터 공연 찾기! 어때요?", "오늘은 뮤지컬 어떠세요?"]
            case .lunch:
                return ["점심 후엔 공연 예매 어때요?", "오늘은 연극 어떠신가요?", "휴식 시간에 공연 찾아볼까요?"]
            case .afternoon:
                return ["오후엔 뮤지컬 어떠세요?", "오늘은 어떤 공연을 볼까요?", "이번 주말 공연 찾아볼까요?"]
            case .evening:
                return ["저녁 시간, 공연 어때요?", "오늘은 연극 어떠신가요?", "주말 공연 예매 어떠세요?"]
            case .lateNight:
                return ["내일 볼 공연 찾아볼까요?", "이번 주말 공연은 어때요?", "다음 주 공연 예매해볼까요?"]
            }
        }
    }
}

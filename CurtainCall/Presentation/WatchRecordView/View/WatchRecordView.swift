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
    private let saveButtonTappedSubject = PublishSubject<Void>()
    private let dateButtonTappedSubject = PublishSubject<Date>()
    private let timeButtonTappedSubject = PublishSubject<Date>()
    private let companionSelectedSubject = PublishSubject<String>()
    private let seatTextChangedSubject = PublishSubject<String>()
    private let ratingChangedSubject = PublishSubject<Int>()
    private let reviewTextChangedSubject = PublishSubject<String>()
    
    // MARK: - Observables
    var saveButtonTapped: Observable<Void> {
        return saveButtonTappedSubject.asObservable()
    }
    
    var dateButtonTapped: Observable<Date> {
        return dateButtonTappedSubject.asObservable()
    }
    
    var timeButtonTapped: Observable<Date> {
        return timeButtonTappedSubject.asObservable()
    }
    
    var companionSelected: Observable<String> {
        return companionSelectedSubject.asObservable()
    }
    
    var seatTextChanged: Observable<String> {
        return seatTextChangedSubject.asObservable()
    }
    
    var ratingChanged: Observable<Int> {
        return ratingChangedSubject.asObservable()
    }
    
    var reviewTextChanged: Observable<String> {
        return reviewTextChangedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .ccBackground
        cv.showsVerticalScrollIndicator = false
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .ccHeadlineBold
        button.backgroundColor = .ccPrimary
        button.layer.cornerRadius = 12
        return button
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
                    .bind(to: dateButtonTappedSubject)
                    .disposed(by: cell.disposeBag)
                
                cell.timeButtonTapped
                    .bind(to: timeButtonTappedSubject)
                    .disposed(by: cell.disposeBag)
                
                cell.companionSelected
                    .bind(to: companionSelectedSubject)
                    .disposed(by: cell.disposeBag)
                
                cell.seatTextChanged
                    .bind(to: seatTextChangedSubject)
                    .disposed(by: cell.disposeBag)
                
                return cell
                
            case .rating:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RatingReviewCell.identifier, for: indexPath) as! RatingReviewCell
                
                // 이벤트 바인딩
                cell.ratingChanged
                    .bind(to: ratingChangedSubject)
                    .disposed(by: cell.disposeBag)
                
                cell.reviewTextChanged
                    .bind(to: reviewTextChangedSubject)
                    .disposed(by: cell.disposeBag)
                
                return cell
                
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
        addSubview(saveButton)
    }
    
    override func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(saveButton.snp.top)
        }
        
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(16)
            make.height.equalTo(56)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        setupCollectionView()
        applyInitialSnapshot()
        setupKeyboardHandling()
        bindActions()
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
        
        collectionView.register(
            RatingReviewCell.self,
            forCellWithReuseIdentifier: RatingReviewCell.identifier
        )
    }
    
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.performanceInfo, .viewingInfo, .rating], toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupKeyboardHandling() {
        // 키보드 높이 감지
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return nil
                }
                return keyboardFrame.height
            }
            .subscribe(with: self) { owner, keyboardHeight in
                owner.collectionView.contentInset.bottom = keyboardHeight
                owner.collectionView.verticalScrollIndicatorInsets.bottom = keyboardHeight
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .subscribe(with: self) { owner, _ in
                owner.collectionView.contentInset.bottom = 0
                owner.collectionView.verticalScrollIndicatorInsets.bottom = 0
            }
            .disposed(by: disposeBag)
    }
    
    private func bindActions() {
        saveButton.rx.tap
            .bind(to: saveButtonTappedSubject)
            .disposed(by: disposeBag)
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

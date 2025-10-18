//
//  WriteRecordView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class WriteRecordView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var performanceDetail: PerformanceDetail?
    private var initialRecordData: ViewingRecordData?
    
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
    private lazy var dataSource: UICollectionViewDiffableDataSource<WriteSection, Item> = {
        let dataSource = UICollectionViewDiffableDataSource<WriteSection, Item>(
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
                
                if let data = self.initialRecordData {
                    cell.configure(
                        date: data.viewingDate,
                        time: data.viewingTime,
                        companion: data.companion,
                        seat: data.seat
                    )
                }
                
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
                
                if let data = self.initialRecordData {
                    cell.configure(
                        rating: data.rating,
                        review: data.review
                    )
                }
                
                return cell
                
            case .memo:
                // TODO: 나중에 구현
                return UICollectionViewCell()
            }
        }
        
        return dataSource
    }()
    
    // MARK: - Public Methods
    func updateSaveButtonState(isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
        saveButton.backgroundColor = isEnabled ? .ccPrimary : .ccButtonDisabled
        saveButton.alpha = isEnabled ? 1.0 : 0.5
    }
    
    func configureWithExistingRecord(_ data: ViewingRecordData) {
        // 초기 데이터 저장
        self.initialRecordData = data
        
        // 각 Subject에 초기 데이터 전달 (ViewModel Relay 동기화용)
        dateButtonTappedSubject.onNext(data.viewingDate)
        timeButtonTappedSubject.onNext(data.viewingTime)
        companionSelectedSubject.onNext(data.companion)
        seatTextChangedSubject.onNext(data.seat)
        ratingChangedSubject.onNext(data.rating)
        reviewTextChangedSubject.onNext(data.review)
        
        // 스냅샷 재적용하여 셀에 데이터 반영
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([.viewingInfo, .rating])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
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
extension WriteRecordView {
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
        var snapshot = NSDiffableDataSourceSnapshot<WriteSection, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.performanceInfo, .viewingInfo, .rating], toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupKeyboardHandling() {
        // 키보드가 나타날 때
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> (CGFloat, TimeInterval, UIView.AnimationCurve)? in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                      let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                      let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
                      let curve = UIView.AnimationCurve(rawValue: curveValue) else {
                    return nil
                }
                return (keyboardFrame.height, duration, curve)
            }
            .subscribe(with: self) { owner, info in
                let (keyboardHeight, _, _) = info
                
                // 키보드 높이만큼 contentInset 조정
                let contentInset = UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: keyboardHeight,
                    right: 0
                )
                owner.collectionView.contentInset = contentInset
                owner.collectionView.verticalScrollIndicatorInsets = contentInset
                
                // 활성화된 입력 필드가 보이도록 스크롤
                owner.fitScrollingMinDistance(keyboardHeight: keyboardHeight)
            }
            .disposed(by: disposeBag)
        
        // 키보드가 사라질 때
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .subscribe(with: self) { owner, _ in
                // contentInset 원상복구
                owner.collectionView.contentInset = .zero
                owner.collectionView.verticalScrollIndicatorInsets = .zero
            }
            .disposed(by: disposeBag)
    }

    private func fitScrollingMinDistance(keyboardHeight: CGFloat) {
        // 현재 first responder 찾기
        guard let activeField = findFirstResponder() else { return }
        
        // superView 결정 (window가 있으면 window, 없으면 collectionView)
        let superView = window ?? collectionView
        
        // activeField의 하단 Y 좌표 계산
        let fieldBottomY = activeField.convert(activeField.bounds, to: superView).maxY
        
        // 키보드를 제외한 보이는 영역의 높이
        let visibleAreaHeight = superView.frame.height - keyboardHeight
        
        // 입력 필드와 키보드 사이 최소 여유 공간
        let minDistance: CGFloat = 20.0
        
        // 필요한 스크롤 오프셋 계산
        let offsetY = fieldBottomY + minDistance - visibleAreaHeight
        
        // offsetY가 양수일 때만 스크롤 (가려진 경우에만)
        guard offsetY > 0 else { return }
        
        // 현재 contentOffset에 필요한 만큼 추가
        let currentContentOffset = collectionView.contentOffset
        let newOffset = CGPoint(
            x: currentContentOffset.x,
            y: currentContentOffset.y + offsetY
        )
        
        // 애니메이션과 함께 스크롤
        collectionView.setContentOffset(newOffset, animated: true)
    }

    private func findFirstResponder() -> UIView? {
        // collectionView의 모든 visible cells를 순회하며 first responder 찾기
        for cell in collectionView.visibleCells {
            if let textView = cell.findFirstResponderInSubviews() {
                return textView
            }
        }
        return nil
    }
    
    private func bindActions() {
        saveButton.rx.tap
            .bind(to: saveButtonTappedSubject)
            .disposed(by: disposeBag)
    }
}

// MARK: - Layout
extension WriteRecordView {
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

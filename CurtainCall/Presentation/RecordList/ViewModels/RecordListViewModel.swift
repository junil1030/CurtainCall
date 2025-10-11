//
//  RecordListViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 10/10/25.
//

import Foundation
import RxSwift
import RxCocoa

final class RecordListViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UseCase
    private let getAllViewingRecordsUseCase: GetAllViewingRecordsUseCase
    
    // MARK: - Relays
    private let allRecordsRelay = BehaviorRelay<[ViewingRecordDTO]>(value: [])
    private let filteredRecordsRelay = BehaviorRelay<[ViewingRecordDTO]>(value: [])
    private let searchQueryRelay = BehaviorRelay<String>(value: "")
    private let selectedCategoryRelay = BehaviorRelay<CategoryCode?>(value: nil)
    private let selectedRatingFiltersRelay = BehaviorRelay<[RatingFilterOption]>(value: [])
    private let sortTypeRelay = BehaviorRelay<RecordSortType>(value: .latest)
    
    private let navigateToDetailRelay = PublishRelay<String>()
    private let navigateToEditRelay = PublishRelay<String>()
    
    // MARK: - Input / Output
    struct Input {
        let viewWillAppear: Observable<Void>
        let searchTextChanged: Observable<String>
        let categorySelected: Observable<CategoryCode?>
        let ratingFilterChanged: Observable<[RatingFilterOption]>
        let sortTypeChanged: Observable<RecordSortType>
        let cellTapped: Observable<String>  // performanceId
        let editButtonTapped: Observable<String>  // record id (String)
    }
    
    struct Output {
        let records: Driver<[ViewingRecordDTO]>
        let filteredCount: Driver<Int>
        let isEmpty: Driver<Bool>
        let navigateToDetail: Signal<String>  // performanceId
        let navigateToEdit: Signal<String>  // record id
    }
    
    // MARK: - Init
    init(getAllViewingRecordsUseCase: GetAllViewingRecordsUseCase) {
        self.getAllViewingRecordsUseCase = getAllViewingRecordsUseCase
        super.init()
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        
        // ViewWillAppear 시 데이터 로드
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                owner.loadRecords()
            }
            .disposed(by: disposeBag)
        
        // 검색어 변경 (0.3초 디바운스)
        input.searchTextChanged
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(to: searchQueryRelay)
            .disposed(by: disposeBag)
        
        // 카테고리 선택
        input.categorySelected
            .bind(to: selectedCategoryRelay)
            .disposed(by: disposeBag)
        
        // 평점 필터 변경
        input.ratingFilterChanged
            .bind(to: selectedRatingFiltersRelay)
            .disposed(by: disposeBag)
        
        // 정렬 타입 변경
        input.sortTypeChanged
            .bind(to: sortTypeRelay)
            .disposed(by: disposeBag)
        
        // 필터링 & 정렬 로직
        Observable.combineLatest(
            allRecordsRelay,
            searchQueryRelay,
            selectedCategoryRelay,
            selectedRatingFiltersRelay,
            sortTypeRelay
        )
        .map { [weak self] allRecords, searchQuery, category, ratingFilters, sortType in
            guard let self = self else { return [] }
            return self.filterAndSortRecords(
                allRecords: allRecords,
                searchQuery: searchQuery,
                category: category,
                ratingFilters: ratingFilters,
                sortType: sortType
            )
        }
        .bind(to: filteredRecordsRelay)
        .disposed(by: disposeBag)
        
        // 셀 탭 -> 상세 화면 이동
        input.cellTapped
            .bind(to: navigateToDetailRelay)
            .disposed(by: disposeBag)
        
        // 편집 버튼 탭 -> 편집 화면 이동 (record id 전달)
        input.editButtonTapped
            .bind(to: navigateToEditRelay)
            .disposed(by: disposeBag)
        
        // Output
        let records = filteredRecordsRelay.asDriver()
        
        let filteredCount = filteredRecordsRelay
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)
        
        let isEmpty = filteredRecordsRelay
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
        
        let navigateToDetail = navigateToDetailRelay.asSignal()
        let navigateToEdit = navigateToEditRelay.asSignal()
        
        return Output(
            records: records,
            filteredCount: filteredCount,
            isEmpty: isEmpty,
            navigateToDetail: navigateToDetail,
            navigateToEdit: navigateToEdit
        )
    }
    
    // MARK: - Private Methods
    private func loadRecords() {
        let records = getAllViewingRecordsUseCase.execute(())
        allRecordsRelay.accept(records)
    }
    
    private func filterAndSortRecords(
        allRecords: [ViewingRecordDTO],
        searchQuery: String,
        category: CategoryCode?,
        ratingFilters: [RatingFilterOption],
        sortType: RecordSortType
    ) -> [ViewingRecordDTO] {
        var filtered = allRecords
        
        // 1. 검색어 필터링
        if !searchQuery.isEmpty {
            filtered = filtered.filter { record in
                record.title.localizedCaseInsensitiveContains(searchQuery) ||
                record.safeLocation.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        // 2. 카테고리 필터링
        if let category = category {
            filtered = filtered.filter { record in
                record.genre == category.displayName
            }
        }
        
        // 3. 평점 필터링
        filtered = RatingFilterOption.filter(filtered, with: ratingFilters)
        
        // 4. 정렬
        let sorted = sortType.sort(filtered)
        
        return sorted
    }
}

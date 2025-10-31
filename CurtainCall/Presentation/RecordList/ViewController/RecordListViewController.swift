//
//  RecordListViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 10/10/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RecordListViewController: BaseViewController {
    
    // MARK: - Properties
    private let recordListView = RecordListView()
    private let viewModel: RecordListViewModel
    private let disposeBag = DisposeBag()
    private let container = DIContainer.shared
    
    // MARK: - Subjects
    private let viewWillAppearSubject = PublishSubject<Void>()
    
    // MARK: - Init
    init(viewModel: RecordListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        view = recordListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearSubject.onNext(())
    }
    
    // MARK: - Override Methods
    override func setupBind() {
        super.setupBind()
        
        let input = RecordListViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            searchTextChanged: recordListView.searchTextChanged,
            categorySelected: recordListView.categorySelected,
            ratingFilterChanged: recordListView.ratingFilterChanged,
            sortTypeChanged: recordListView.sortTypeChanged,
            cellTapped: recordListView.cellTapped,
            editButtonTapped: recordListView.editButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        output.records
            .drive(with: self) { owner, records in
                owner.recordListView.updateRecords(records: records)
            }
            .disposed(by: disposeBag)
        
        output.filteredCount
            .drive(with: self) { owner, count in
                owner.recordListView.updateFilteredCount(count)
            }
            .disposed(by: disposeBag)
        
        output.isEmpty
            .drive(with: self) { owner, isEmpty in
                owner.recordListView.updateEmptyState(isEmpty: isEmpty)
            }
            .disposed(by: disposeBag)
        
        output.navigateToDetail
            .emit(with: self) { owner, performanceId in
                owner.navigateToDetailView(with: performanceId)
            }
            .disposed(by: disposeBag)
        
        output.navigateToEdit
            .emit(with: self) { owner, recordId in
                owner.navigateToEdit(recordId: recordId)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.title = "관람 기록"
    }
}

// MARK: - Navigation
extension RecordListViewController {
    private func navigateToDetailView(with id: String) {
        let viewModel = container.makeDetailViewModel(performanceID: id)
        let viewController = DetailViewController(viewModel: viewModel)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToEdit(recordId: String) {
        let viewModel = container.makeWriteRecordViewModel(mode: .edit(recordId: recordId))
        let viewController = WriteRecordViewController(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

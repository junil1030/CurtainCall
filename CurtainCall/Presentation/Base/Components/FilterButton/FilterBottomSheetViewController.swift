//
//  FilterBottomSheetViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 10/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class FilterBottomSheetViewController: UIViewController {
    
    // MARK: - Types
    enum ContentType {
        case selection(items: [SelectionItem])
        case datePicker(allowFuture: Bool, initialDate: Date)
        case timePicker(initialTime: Date)
    }
    
    struct SelectionItem {
        let title: String
        let value: Any
    }
    
    // MARK: - Constants
    private enum Metric {
        static let maxHeightRatio: CGFloat = 0.6
        static let cornerRadius: CGFloat = 20
        static let dragIndicatorWidth: CGFloat = 40
        static let dragIndicatorHeight: CGFloat = 4
        static let closeButtonHeight: CGFloat = 52
        static let rowHeight: CGFloat = 52
    }
    
    // MARK: - Properties
    private let contentType: ContentType
    private let disposeBag = DisposeBag()
    
    // MARK: - Subjects
    private let selectionSubject = PublishSubject<Any>()
    
    // MARK: - Public Observables
    var selection: Observable<Any> {
        return selectionSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccBackground
        view.layer.cornerRadius = Metric.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let dragIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .ccSeparator
        view.layer.cornerRadius = Metric.dragIndicatorHeight / 2
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.register(FilterBottomSheetCell.self, forCellReuseIdentifier: FilterBottomSheetCell.identifier)
        table.rowHeight = Metric.rowHeight
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    private lazy var customDatePickerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var customTimePickerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var customDatePickerVC: CustomDatePickerView?
    private var customTimePickerVC: CustomTimePickerView?
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(.ccPrimaryText, for: .normal)
        button.titleLabel?.font = .ccBodyBold
        button.backgroundColor = .ccBackground
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccSeparator
        return view
    }()
    
    // MARK: - Init
    init(contentType: ContentType) {
        self.contentType = contentType
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()

        // ⚠️ IMPORTANT: child view controller 추가 전에 미리 화면 밖으로 이동
        // 이렇게 하지 않으면 child의 viewWillAppear가 호출될 때 화면에 보임
        containerView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)

        setupActions()
        setupContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showBottomSheet()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(dimmingView)
        view.addSubview(containerView)
        
        containerView.addSubview(dragIndicator)
        containerView.addSubview(separatorView)
        containerView.addSubview(closeButton)
        
        switch contentType {
        case .selection:
            containerView.addSubview(tableView)
        case .datePicker:
            containerView.addSubview(customDatePickerContainer)
        case .timePicker:
            containerView.addSubview(customTimePickerContainer)
        }
    }
    
    private func setupLayout() {
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let maxHeight = view.bounds.height * Metric.maxHeightRatio
        let contentHeight = calculateContentHeight()
        let finalHeight = min(contentHeight, maxHeight)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(finalHeight)
        }
        
        dragIndicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(Metric.dragIndicatorWidth)
            make.height.equalTo(Metric.dragIndicatorHeight)
        }
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(closeButton.snp.top)
            make.height.equalTo(1)
        }
        
        closeButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(Metric.closeButtonHeight)
        }
        
        switch contentType {
        case .selection:
            tableView.snp.makeConstraints { make in
                make.top.equalTo(dragIndicator.snp.bottom).offset(8)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(separatorView.snp.top)
            }
            
        case .datePicker:
            customDatePickerContainer.snp.makeConstraints { make in
                make.top.equalTo(dragIndicator.snp.bottom).offset(8)
                make.leading.trailing.equalToSuperview().inset(20)
                make.bottom.equalTo(separatorView.snp.top).offset(-8)
            }
            
        case .timePicker:
            customTimePickerContainer.snp.makeConstraints { make in
                make.top.equalTo(dragIndicator.snp.bottom).offset(8)
                make.leading.trailing.equalToSuperview().inset(20)
                make.bottom.equalTo(separatorView.snp.top).offset(-8)
            }
        }
    }
    
    private func setupActions() {
        // 딤뷰 탭 제스처
        let tapGesture = UITapGestureRecognizer()
        dimmingView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        // 닫기 버튼
        closeButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupContent() {
        switch contentType {
        case .selection(let items):
            setupTableView(with: items)
            
        case .datePicker(let allowFuture, let initialDate):
            setupDatePicker(allowFuture: allowFuture, initialDate: initialDate)
            
        case .timePicker(let initialTime):
            setupTimePicker(initialTime: initialTime)
        }
    }
    
    private func setupTableView(with items: [SelectionItem]) {
        Observable.just(items)
            .bind(to: tableView.rx.items(
                cellIdentifier: FilterBottomSheetCell.identifier,
                cellType: FilterBottomSheetCell.self
            )) { index, item, cell in
                cell.configure(with: item.title)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(with: self) { owner, indexPath in
                owner.tableView.deselectRow(at: indexPath, animated: true)
                let selectedItem = items[indexPath.row]
                owner.selectionSubject.onNext(selectedItem.value)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupDatePicker(allowFuture: Bool, initialDate: Date) {
        let datePickerVC = CustomDatePickerView(
            initialDate: initialDate,
            allowFuture: allowFuture
        )

        addChild(datePickerVC)
        customDatePickerContainer.addSubview(datePickerVC.view)
        datePickerVC.didMove(toParent: self)

        datePickerVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        customDatePickerVC = datePickerVC

        datePickerVC.selectedDate
            .subscribe(with: self) { owner, date in
                owner.selectionSubject.onNext(date)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupTimePicker(initialTime: Date) {
        let timePickerVC = CustomTimePickerView(initialDate: initialTime)
        
        addChild(timePickerVC)
        customTimePickerContainer.addSubview(timePickerVC.view)
        timePickerVC.didMove(toParent: self)
        
        timePickerVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        customTimePickerVC = timePickerVC
        
        timePickerVC.selectedTime
            .subscribe(with: self) { owner, time in
                owner.selectionSubject.onNext(time)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Animation
    private func showBottomSheet() {
        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut
        ) {
            self.containerView.transform = .identity
            self.dimmingView.alpha = 1
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.containerView.transform = CGAffineTransform(
                    translationX: 0,
                    y: self.containerView.bounds.height
                )
                self.dimmingView.alpha = 0
            },
            completion: { _ in
                super.dismiss(animated: false, completion: completion)
            }
        )
    }
    
    // MARK: - Helper Methods
    private func calculateContentHeight() -> CGFloat {
        let topPadding: CGFloat = 12 + Metric.dragIndicatorHeight + 8
        let bottomPadding: CGFloat = Metric.closeButtonHeight + 1
        
        switch contentType {
        case .selection(let items):
            let tableHeight = CGFloat(items.count + 1) * Metric.rowHeight
            return topPadding + tableHeight + bottomPadding
            
        case .datePicker:
            let pickerHeight: CGFloat = 480
            return topPadding + pickerHeight + bottomPadding
            
        case .timePicker:
            let pickerHeight: CGFloat = 300
            return topPadding + pickerHeight + bottomPadding
        }
    }
}

// MARK: - FilterBottomSheetCell
final class FilterBottomSheetCell: UITableViewCell {
    
    static let identifier = "FilterBottomSheetCell"
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccBody
        label.textColor = .ccPrimaryText
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Highlight
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.2) {
            self.contentView.backgroundColor = highlighted ?
                UIColor.ccSeparator.withAlphaComponent(0.3) : .clear
        }
    }
}

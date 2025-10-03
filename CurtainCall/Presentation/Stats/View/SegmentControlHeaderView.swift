//
//  SegmentControlHeaderView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SegmentControlHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    static let identifier = "SegmentControlHeaderView"
    private(set) var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: StatsPeriod.allCases.map { $0.rawValue })
        control.selectedSegmentIndex = 1
        control.backgroundColor = .white
        control.selectedSegmentTintColor = .ccPrimary
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        
        return control
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccBackground
        return view
    }()
    
    // MARK: - Observables
    private let periodSelectedSubject = PublishSubject<StatsPeriod>()
    
    var periodSelected: Observable<StatsPeriod> {
        return periodSelectedSubject.asObservable()
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupHierarchy()
        setupLayout()
        setupStyle()
        setupBind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        setupBind()
    }
    
    // MARK: - Setup
    private func setupHierarchy() {
        addSubview(containerView)
        containerView.addSubview(segmentControl)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        segmentControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(44)
        }
    }
    
    private func setupStyle() {
        backgroundColor = .ccBackground
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }
    
    private func setupBind() {
        segmentControl.rx.selectedSegmentIndex
            .map { index -> StatsPeriod in
                return StatsPeriod.allCases[index]
            }
            .bind(to: periodSelectedSubject)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Methods
    
    /// 현재 선택된 기간 설정
    func configure(selectedPeriod: StatsPeriod) {
        if let index = StatsPeriod.allCases.firstIndex(of: selectedPeriod) {
            segmentControl.selectedSegmentIndex = index
        }
    }
}

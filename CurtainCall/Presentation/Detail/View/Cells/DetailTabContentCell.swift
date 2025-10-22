//
//  DetailTabContentCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/21/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DetailTabContentCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let cellDisposeBag = DisposeBag()  // Cell의 생명주기 동안 유지
    private var currentTab: DetailTab = .info
    
    // MARK: - Subjects
    private let bookingSiteSelectedSubject = PublishSubject<String>()
    
    // MARK: - Observables
    var bookingSiteSelected: Observable<String> {
        return bookingSiteSelectedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let tabBar = DetailTabBar()
    private let containerView = UIView()
    
    // MARK: - Content Views
    private let performanceInfoView = PerformanceInfoView()
    private let bookingInfoView = BookingInfoView()
    private let castInfoView = CastInfoView()
    private let productionInfoView = ProductionInfoView()
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        currentTab = .info
        tabBar.selectTab(.info, animated: false)
        showContentView(for: .info)
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(tabBar)
        contentView.addSubview(containerView)
        
        [performanceInfoView, bookingInfoView, castInfoView, productionInfoView].forEach {
            containerView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        tabBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(tabBar.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(150)
        }
        
        [performanceInfoView, bookingInfoView, castInfoView, productionInfoView].forEach { view in
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .ccBackground
        
        // 초기 상태: 공연정보만 표시
        showContentView(for: .info)
        
        // 탭 선택 이벤트
        tabBar.tabSelected
            .subscribe(with: self) { owner, tab in
                owner.showContentView(for: tab)
            }
            .disposed(by: cellDisposeBag)
        
        // 예매 버튼 탭 이벤트 전달
        bookingInfoView.bookingSiteSelected
            .bind(to: bookingSiteSelectedSubject)
            .disposed(by: cellDisposeBag)
    }
    
    // MARK: - Public Methods
    func configure(with detail: PerformanceDetail) {
        performanceInfoView.configure(with: detail)
        bookingInfoView.configure(with: detail.bookingSites)
        castInfoView.configure(with: detail.cast)
        productionInfoView.configure(with: detail)
    }
    
    // MARK: - Private Methods
    private func showContentView(for tab: DetailTab) {
        currentTab = tab
        
        performanceInfoView.isHidden = (tab != .info)
        bookingInfoView.isHidden = (tab != .booking)
        castInfoView.isHidden = (tab != .cast)
        productionInfoView.isHidden = (tab != .production)
    }
}

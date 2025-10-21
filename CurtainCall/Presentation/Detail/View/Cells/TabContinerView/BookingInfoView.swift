//
//  BookingInfoView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/21/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class BookingInfoView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Subjects
    private let bookingSiteSelectedSubject = PublishSubject<String>()
    
    // MARK: - Observables
    var bookingSiteSelected: Observable<String> {
        return bookingSiteSelectedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "예매 가능한 사이트 정보가 없어요"
        label.font = .ccBody
        label.textColor = .ccSecondaryText
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(scrollView)
        addSubview(emptyLabel)
        scrollView.addSubview(stackView)
    }
    
    override func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalToSuperview().offset(-40)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
    }
    
    // MARK: - Public Methods
    func configure(with bookingSites: [BookingSite]?) {
        // 기존 버튼 제거
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        guard let sites = bookingSites, !sites.isEmpty else {
            emptyLabel.isHidden = false
            scrollView.isHidden = true
            return
        }
        
        emptyLabel.isHidden = true
        scrollView.isHidden = false
        
        // 각 예매 사이트 버튼 생성
        sites.forEach { site in
            let button = createBookingButton(for: site)
            stackView.addArrangedSubview(button)
            
            button.snp.makeConstraints { make in
                make.height.equalTo(50)
            }
        }
    }
    
    // MARK: - Private Methods
    private func createBookingButton(for site: BookingSite) -> UIButton {
        let button = UIButton()
        
        // Configuration 설정
        var config = UIButton.Configuration.plain()
        config.title = site.name
        config.baseForegroundColor = .ccPrimary
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        button.configuration = config
        button.titleLabel?.font = .ccCallout
        button.backgroundColor = .ccSecondary
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ccPrimary.cgColor
        
        // 탭 이벤트
        button.rx.tap
            .map { site.url }
            .bind(to: bookingSiteSelectedSubject)
            .disposed(by: disposeBag)
        
        return button
    }
}

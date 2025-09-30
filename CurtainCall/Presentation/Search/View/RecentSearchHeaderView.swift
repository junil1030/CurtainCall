//
//  RecentSearchHeaderView.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import UIKit
import RxSwift
import SnapKit

final class RecentSearchHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    static let identifier = "RecentSearchHeaderView"
    var disposeBag = DisposeBag()
    
    // MARK: - Subjects
    private let deleteAllTappedSubject = PublishSubject<Void>()
    
    // MARK: - Observables
    var deleteAllTapped: Observable<Void> {
        return deleteAllTappedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 검색"
        label.font = .ccBodyBold
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let deleteAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("전체 삭제", for: .normal)
        button.setTitleColor(.ccSecondaryText, for: .normal)
        button.titleLabel?.font = .ccCallout
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .ccBackground
        
        addSubview(titleLabel)
        addSubview(deleteAllButton)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        deleteAllButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        deleteAllButton.rx.tap
            .bind(to: deleteAllTappedSubject)
            .disposed(by: disposeBag)
    }
}

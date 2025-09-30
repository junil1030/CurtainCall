//
//  RecentSearchCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/30/25.
//

import UIKit
import RxSwift
import SnapKit

final class RecentSearchCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Subjects
    private let deleteButtonTappedSubject = PublishSubject<Void>()
    
    // MARK: - Observables
    var deleteButtonTapped: Observable<Void> {
        return deleteButtonTappedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let clockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock")
        imageView.tintColor = .ccSecondaryText
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let keywordLabel: UILabel = {
        let label = UILabel()
        label.font = .ccBody
        label.textColor = .ccPrimaryText
        label.numberOfLines = 1
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .ccSecondaryText
        return button
    }()
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        keywordLabel.text = nil
    }
    
    // MARK: - Setup
    override func setupHierarchy() {
        super.setupHierarchy()
        
        [clockImageView, keywordLabel, deleteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        clockImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        keywordLabel.snp.makeConstraints { make in
            make.leading.equalTo(clockImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(deleteButton.snp.leading).offset(-12)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
        
        deleteButton.rx.tap
            .bind(to: deleteButtonTappedSubject)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    func configure(with search: RecentSearch) {
        keywordLabel.text = search.keyword
    }
}

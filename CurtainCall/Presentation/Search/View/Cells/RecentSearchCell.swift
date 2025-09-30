//
//  RecentSearchCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class RecentSearchCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
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
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Subjects
    private let deleteButtonTappedSubject = PublishSubject<Void>()
    
    // MARK: - Observables
    var deleteButtonTapped: Observable<Void> {
        return deleteButtonTappedSubject.asObservable()
    }
    
    // MARK: - Override Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        keywordLabel.text = nil
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(clockImageView)
        stackView.addArrangedSubview(keywordLabel)
        stackView.addArrangedSubview(deleteButton)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        clockImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        keywordLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        keywordLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .ccBackground
        
        deleteButton.rx.tap
            .bind(to: deleteButtonTappedSubject)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    func configure(with recentSearch: RecentSearch) {
        keywordLabel.text = recentSearch.keyword
    }
}

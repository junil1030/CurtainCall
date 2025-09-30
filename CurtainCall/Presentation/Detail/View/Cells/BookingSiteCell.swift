//
//  BookingSiteCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import SnapKit
import RxSwift

final class BookingSiteCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Subjects
    private let buttonTappedSubject = PublishSubject<Void>()
    
    // MARK: - Observables
    var buttonTapped: Observable<Void> {
        return buttonTappedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let bookingButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.baseForegroundColor = .ccPrimary
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .ccCallout
        button.backgroundColor = .ccSecondary
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ccPrimary.cgColor
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        contentView.addSubview(bookingButton)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        bookingButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        bookingButton.rx.tap
            .bind(to: buttonTappedSubject)
            .disposed(by: disposeBag)
    }
    
    func configure(with site: BookingSite) {
        bookingButton.setTitle(site.name, for: .normal)
    }
}

//
//  CategoryCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/26/25.
//

import UIKit
import RxSwift
import SnapKit

final class CategoryCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "CategoryCell"
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccPrimary
        view.layer.cornerRadius = 1
        view.isHidden = true
        return view
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
        titleLabel.text = nil
        underlineView.isHidden = true
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(underlineView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(underlineView.snp.top).offset(-4)
        }
        
        underlineView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(3)
        }
    }
    
    // MARK: - Configure
    func configure(with category: CategoryCode, isSelected: Bool) {
        titleLabel.text = category.displayName
        updateAppearance(isSelected: isSelected)
    }
    
    private func updateAppearance(isSelected: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.underlineView.isHidden = !isSelected
            self?.titleLabel.font = isSelected ? .ccCalloutBold : .ccCallout
        }
    }
}

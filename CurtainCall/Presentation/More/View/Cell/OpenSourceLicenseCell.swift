//
//  OpenSourceLicenseCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import UIKit
import SnapKit

final class OpenSourceLicenseCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "OpenSourceLicenseCell"
    
    // MARK: - UI Components
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .ccBody
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ccSecondaryText
        return imageView
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
        selectionStyle = .none
        backgroundColor = .ccBackground
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(chevronImageView)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(12)
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(8)
        }
    }
    
    // MARK: - Configure
    func configure(with license: OpenSourceLicense) {
        nameLabel.text = license.name
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

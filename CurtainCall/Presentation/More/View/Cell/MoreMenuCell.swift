//
//  MoreMenuCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit
import SnapKit

final class MoreMenuCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "MoreMenuCell"
    
    // MARK: - UI Components
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ccPrimary
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccBody
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccSecondaryText
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
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(versionLabel)
        contentView.addSubview(chevronImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        versionLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(12)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
        }
    }
    
    // MARK: - Configure
    func configure(with item: MoreMenuItem) {
        iconImageView.image = item.icon
        titleLabel.text = item.title
        
        if item.showsVersion {
            versionLabel.text = DeviceInfo.getAppVersion()
            versionLabel.isHidden = false
            chevronImageView.isHidden = true
        } else {
            versionLabel.isHidden = true
            chevronImageView.isHidden = false
        }
    }
    
    // MARK: - Highlight
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        guard !versionLabel.isHidden else {
            UIView.animate(withDuration: 0.2) {
                self.contentView.backgroundColor = highlighted ?
                    UIColor.ccSeparator.withAlphaComponent(0.3) : .clear
            }
            return
        }
    }
}

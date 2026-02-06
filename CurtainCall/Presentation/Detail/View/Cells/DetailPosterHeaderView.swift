//
//  DetailPosterHeaderView.swift
//  CurtainCall
//
//  Created by 서준일 on 2/6/26.
//

import UIKit
import SnapKit

final class DetailPosterHeaderView: UICollectionReusableView {

    static let identifier = "DetailPosterHeaderView"

    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "상세 정보"
        label.font = .ccHeadlineBold
        label.textColor = .ccPrimaryText
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupLayout()
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupHierarchy() {
        addSubview(titleLabel)
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

    private func setupStyle() {
        backgroundColor = .ccBackground
    }
}

//
//  GenreAnalysisCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import UIKit
import SnapKit

final class GenreAnalysisCell: BaseCollectionViewCell {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .ccSecondaryText
        return label
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let progressBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    private let progressFillView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - Properties
    private var progressWidthConstraint: Constraint?
    
    // MARK: - Override Methods
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(genreLabel)
        containerView.addSubview(countLabel)
        containerView.addSubview(percentageLabel)
        containerView.addSubview(progressBackgroundView)
        
        progressBackgroundView.addSubview(progressFillView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        genreLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        
        countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(genreLabel)
            make.leading.equalTo(genreLabel.snp.trailing).offset(8)
        }
        
        percentageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(genreLabel)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        progressBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(genreLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(8)
        }
        
        progressFillView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            progressWidthConstraint = make.width.equalTo(0).constraint
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .clear
    }
    
    // MARK: - Configure
    
    func configure(with item: GenreAnalysisItem) {
        genreLabel.text = item.genre
        countLabel.text = "\(item.count)편"
        percentageLabel.text = item.percentageText
        
        // 장르별 색상 설정
        let genreColor = getGenreColor(for: item.genre)
        progressFillView.backgroundColor = genreColor
        
        // 프로그레스 바 애니메이션
        layoutIfNeeded()
        
        let maxWidth = progressBackgroundView.frame.width
        let targetWidth = maxWidth * (item.percentage / 100.0)
        
        progressWidthConstraint?.update(offset: targetWidth)
        
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Helper
    
    private func getGenreColor(for genre: String) -> UIColor {
        switch genre {
        case "뮤지컬":
            return .ccMusicalChart
        case "연극":
            return .ccPlayChart
        case "클래식":
            return .ccClassicChart
        case "무용":
            return .ccDanceChart
        case "대중음악":
            return .ccPopularMusicChart
        case "복합":
            return .ccComplexChart
        case "서커스/마술":
            return .ccCircus_MagicChart
        case "기타":
            return .ccSomeChart
        default:
            return UIColor.ccPrimary
        }
    }
}

//
//  RecordListCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/10/25.
//

import UIKit
import RxSwift
import SnapKit
import Kingfisher

final class RecordListCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Constants
    private enum Metric {
        static let posterWidth: CGFloat = 60
        static let posterHeight: CGFloat = 85
        static let posterCornerRadius: CGFloat = 8
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 12
        static let contentSpacing: CGFloat = 12
        static let infoSpacing: CGFloat = 4
        static let editButtonSize: CGFloat = 32
    }
    
    // MARK: - Subjects
    private let editButtonTappedSubject = PublishSubject<Void>()
    
    // MARK: - Observables
    var editButtonTapped: Observable<Void> {
        return editButtonTappedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Metric.posterCornerRadius
        imageView.backgroundColor = .ccDisabledBackground
        return imageView
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccBodyBold
        label.textColor = .ccPrimaryText
        label.numberOfLines = 2
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()
    
    private let dateInfoView: InfoItemView = {
        let view = InfoItemView()
        return view
    }()
    
    private let locationInfoView: InfoItemView = {
        let view = InfoItemView()
        return view
    }()
    
    private let starRatingView: StarRatingView = {
        let view = StarRatingView(rating: 0, isEnabled: false)
        return view
    }()
    
    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCallout
        label.textColor = .ccSecondaryText
        label.numberOfLines = 2
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .ccSecondaryText
        button.backgroundColor = .ccBackground
        button.layer.cornerRadius = Metric.editButtonSize / 2
        return button
    }()
    
    // MARK: - Override Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        titleLabel.text = nil
        memoLabel.text = nil
        starRatingView.setRating(0)
        bindActions()
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(posterImageView)
        containerView.addSubview(contentStackView)
        containerView.addSubview(editButton)
        
        infoStackView.addArrangedSubview(dateInfoView)
        infoStackView.addArrangedSubview(locationInfoView)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(infoStackView)
        contentStackView.addArrangedSubview(starRatingView)
        contentStackView.addArrangedSubview(memoLabel)
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        posterImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metric.horizontalInset)
            make.top.equalToSuperview().inset(Metric.verticalInset)
            make.width.equalTo(Metric.posterWidth)
            make.height.equalTo(Metric.posterHeight)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Metric.verticalInset)
            make.trailing.equalToSuperview().inset(Metric.horizontalInset)
            make.width.height.equalTo(Metric.editButtonSize)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.leading.equalTo(posterImageView.snp.trailing).offset(Metric.contentSpacing)
            make.trailing.equalTo(editButton.snp.leading).offset(-8)
            make.top.equalToSuperview().inset(Metric.verticalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(Metric.verticalInset)
        }
        
        starRatingView.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(16)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .clear
        
        bindActions()
    }
    
    // MARK: - Binding
    private func bindActions() {
        editButton.rx.tap
            .bind(to: editButtonTappedSubject)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    func configure(with record: ViewingRecordDTO) {
        // 포스터 이미지
        posterImageView.kf.setImage(
            with: record.posterURL.safeImageURL,
            placeholder: UIImage(systemName: "photo"),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
        
        // 제목
        titleLabel.text = record.title
        
        // 날짜
        let dateString = record.viewingDate.toDateWithWeekday
        dateInfoView.configure(symbol: "calendar", text: dateString, symbolColor: .ccPrimaryText)
        
        // 장소
        locationInfoView.configure(symbol: "location.fill", text: record.location, symbolColor: .ccPrimaryText)
        
        // 별점
        starRatingView.setRating(record.rating)
        
        // 한줄평
        if record.memo.isEmpty {
            memoLabel.isHidden = true
        } else {
            memoLabel.isHidden = false
            memoLabel.text = record.memo
        }
    }
}

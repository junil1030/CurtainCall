//
//  RatingReviewCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import SnapKit

final class RatingReviewCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let maxCharacterCount = 1000
    
    // MARK: - Public Access
    var reviewTextView: UITextView {
        return _reviewTextView
    }
    
    // MARK: - Subjects
    private let ratingChangedSubject = PublishSubject<Int>()
    private let reviewTextChangedSubject = PublishSubject<String>()
    
    // MARK: - Observables
    var ratingChanged: Observable<Int> {
        return ratingChangedSubject.asObservable()
    }
    
    var reviewTextChanged: Observable<String> {
        return reviewTextChangedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        return stack
    }()
    
    // 평점 섹션
    private let ratingRowStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()
    
    private let ratingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "평점"
        label.font = .ccBodyBold
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let starRatingView = StarRatingView()
    
    // 한줄평 섹션
    private let reviewRowStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    private let reviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "한줄평"
        label.font = .ccBodyBold
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let _reviewTextView: UITextView = {
        let textView = UITextView()
        textView.font = .ccCallout
        textView.textColor = .ccPrimaryText
        textView.backgroundColor = .ccBackground
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.ccSeparator.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.isScrollEnabled = true
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "공연에 대한 후기를 남겨보세요"
        label.font = .ccCallout
        label.textColor = .ccSecondaryText
        return label
    }()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.text = "(0/1000자)"
        label.font = .ccCaption2
        label.textColor = .ccSecondaryText
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Override Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        _reviewTextView.text = ""
        placeholderLabel.isHidden = false
        starRatingView.setRating(0)
        updateCharacterCount(0)
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerStackView)
        
        // 평점 섹션
        ratingRowStackView.addArrangedSubview(ratingTitleLabel)
        ratingRowStackView.addArrangedSubview(starRatingView)
        
        // 한줄평 섹션
        _reviewTextView.addSubview(placeholderLabel)
        reviewRowStackView.addArrangedSubview(reviewTitleLabel)
        reviewRowStackView.addArrangedSubview(_reviewTextView)
        reviewRowStackView.addArrangedSubview(characterCountLabel)
        
        // 전체 컨테이너에 추가
        containerStackView.addArrangedSubview(ratingRowStackView)
        containerStackView.addArrangedSubview(reviewRowStackView)
    }
    
    override func setupLayout() {
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        starRatingView.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        _reviewTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(100)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(12)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        bindObservables()
    }
    
    // MARK: - Binding
    private func bindObservables() {
        starRatingView.ratingChanged
            .bind(to: ratingChangedSubject)
            .disposed(by: disposeBag)
        
        // 텍스트 변경 처리
        _reviewTextView.rx.text.orEmpty
            .subscribe(with: self) { owner, text in
                // 1000자 제한
                let limitedText = String(text.prefix(owner.maxCharacterCount))
                if text != limitedText {
                    owner._reviewTextView.text = limitedText
                }
                
                // Placeholder 표시/숨김
                owner.placeholderLabel.isHidden = !limitedText.isEmpty
                
                // 글자 수 업데이트
                owner.updateCharacterCount(limitedText.count)
                
                // 이벤트 방출
                owner.reviewTextChangedSubject.onNext(limitedText)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func updateCharacterCount(_ count: Int) {
        characterCountLabel.text = "(\(count)/\(maxCharacterCount)자)"
    }
    
    // MARK: - Configure
    func configure(rating: Int, review: String) {
        // 별점 설정
        starRatingView.setRating(rating)
        
        // 리뷰 설정
        _reviewTextView.text = review
        placeholderLabel.isHidden = !review.isEmpty
        reviewTextChangedSubject.onNext(review)
    }
}

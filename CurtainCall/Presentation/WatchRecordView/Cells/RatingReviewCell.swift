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
    
    private let starsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var starButtons: [UIButton] = {
        return (0..<5).map { index in
            let button = UIButton()
            button.tag = index
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.setImage(UIImage(systemName: "star.fill"), for: .selected)
            button.tintColor = .ccSecondaryText
            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
            button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
            button.setPreferredSymbolConfiguration(config, forImageIn: .selected)
            return button
        }
    }()
    
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
    
    private let reviewTextView: UITextView = {
        let textView = UITextView()
        textView.font = .ccCallout
        textView.textColor = .ccPrimaryText
        textView.backgroundColor = .ccBackground
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.ccSeparator.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.isScrollEnabled = false
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
    
    // MARK: - State
    private var currentRating: Int = 0
    
    // MARK: - Override Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        reviewTextView.text = ""
        placeholderLabel.isHidden = false
        currentRating = 0
        updateStarAppearance()
        updateCharacterCount(0)
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(containerStackView)
        
        // 평점 섹션
        ratingRowStackView.addArrangedSubview(ratingTitleLabel)
        ratingRowStackView.addArrangedSubview(starsStackView)
        
        starButtons.forEach { button in
            starsStackView.addArrangedSubview(button)
        }
        
        // 한줄평 섹션
        reviewTextView.addSubview(placeholderLabel)
        reviewRowStackView.addArrangedSubview(reviewTitleLabel)
        reviewRowStackView.addArrangedSubview(reviewTextView)
        reviewRowStackView.addArrangedSubview(characterCountLabel)
        
        // 전체 컨테이너에 추가
        containerStackView.addArrangedSubview(ratingRowStackView)
        containerStackView.addArrangedSubview(reviewRowStackView)
    }
    
    override func setupLayout() {
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        starButtons.forEach { button in
            button.snp.makeConstraints { make in
                make.width.height.equalTo(44)
            }
        }
        
        reviewTextView.snp.makeConstraints { make in
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
        // 별 버튼 탭 처리
        starButtons.forEach { button in
            button.rx.tap
                .subscribe(with: self) { owner, _ in
                    let rating = button.tag + 1
                    owner.handleRatingTap(rating: rating)
                }
                .disposed(by: disposeBag)
        }
        
        // 텍스트 변경 처리
        reviewTextView.rx.text.orEmpty
            .subscribe(with: self) { owner, text in
                // 1000자 제한
                let limitedText = String(text.prefix(owner.maxCharacterCount))
                if text != limitedText {
                    owner.reviewTextView.text = limitedText
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
    private func handleRatingTap(rating: Int) {
        // 같은 별을 다시 누르면 평점 초기화
        if currentRating == rating {
            currentRating = 0
        } else {
            currentRating = rating
        }
        
        updateStarAppearance()
        ratingChangedSubject.onNext(currentRating)
    }
    
    private func updateStarAppearance() {
        starButtons.enumerated().forEach { index, button in
            let isFilled = index < currentRating
            button.isSelected = isFilled
            button.tintColor = isFilled ? .systemYellow : .ccSecondaryText
        }
    }
    
    private func updateCharacterCount(_ count: Int) {
        characterCountLabel.text = "(\(count)/\(maxCharacterCount)자)"
    }
    
    // MARK: - Configure
    func configure(rating: Int, review: String) {
        // 별점 설정
        updateStarButtons(rating: rating)
        ratingChangedSubject.onNext(rating)
        
        // 리뷰 설정
        reviewTextView.text = review
        placeholderLabel.isHidden = !review.isEmpty
        reviewTextChangedSubject.onNext(review)
    }

    private func updateStarButtons(rating: Int) {
        for (index, button) in starButtons.enumerated() {
            let isFilled = index < rating
            let imageName = isFilled ? "star.fill" : "star"
            button.setImage(UIImage(systemName: imageName), for: .normal)
            button.tintColor = isFilled ? .systemYellow : .systemGray3
        }
    }
}

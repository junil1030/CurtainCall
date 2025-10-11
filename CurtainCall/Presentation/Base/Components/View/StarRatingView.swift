//
//  StarRatingView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/10/25.
//

import UIKit
import RxSwift
import SnapKit

final class StarRatingView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let maxRating: Int = 5
    private let starSize: CGFloat = 44
    private let starSpacing: CGFloat = 8
    
    private var currentRating: Int
    private let isEnabled: Bool
    
    // MARK: - Subjects
    private let ratingChangedSubject = PublishSubject<Int>()
    
    // MARK: - Observables
    var ratingChanged: Observable<Int> {
        return ratingChangedSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var starButtons: [UIButton] = {
        return (0..<maxRating).map { index in
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
    
    // MARK: - Init
    init(rating: Int = 0, isEnabled: Bool = true) {
        self.currentRating = max(0, min(rating, maxRating))
        self.isEnabled = isEnabled
        
        super.init(frame: .zero)
        
        updateStarAppearance()
        
        if isEnabled {
            bindStarButtons()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(stackView)
        
        starButtons.forEach { button in
            stackView.addArrangedSubview(button)
        }
    }
    
    override func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        starButtons.forEach { button in
            button.snp.makeConstraints { make in
                make.width.height.lessThanOrEqualTo(starSize)
                make.width.equalTo(button.snp.height)
            }
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .clear
    }
    
    // MARK: - Binding
    private func bindStarButtons() {
        starButtons.forEach { button in
            button.rx.tap
                .subscribe(with: self) { owner, _ in
                    let rating = button.tag + 1
                    owner.handleRatingTap(rating: rating)
                }
                .disposed(by: disposeBag)
        }
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
    
    // MARK: - Public Methods
    func setRating(_ rating: Int) {
        currentRating = max(0, min(rating, maxRating))
        updateStarAppearance()
    }
    
    func getRating() -> Int {
        return currentRating
    }
}

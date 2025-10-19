//
//  FavoriteHeaderView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import SnapKit

final class FavoriteHeaderView: BaseView {
    
    // MARK: - Types
    enum SortType: String, CaseIterable {
        case latest = "최신순"
        case oldest = "오래된순"
        case nameAscending = "제목 오름차순"
        case nameDescending = "제목 내림차순"
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccBackground
        return view
    }()
    
    private let statisticsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    private let totalCountView = StatisticsItemView(
        icon: UIImage(systemName: "heart.fill"),
        title: "전체"
    )
    
    private let monthlyCountView = StatisticsItemView(
        icon: UIImage(systemName: "calendar"),
        title: "이번 달"
    )
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ccSeparator
        return view
    }()
    
    // 필터 버튼들
    private let filterStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var sortButton: DropdownFilterButton = {
        let items = SortType.allCases.map { type in
            DropdownFilterButton.Item(title: type.rawValue, value: type)
        }
        let button = DropdownFilterButton(items: items, title: SortType.latest.rawValue)
        return button
    }()
    
    private lazy var genreButton: DropdownFilterButton = {
        var items = [DropdownFilterButton.Item(title: "전체장르", value: "all")]
        items += GenreCode.allCases.map { genre in
            DropdownFilterButton.Item(title: genre.displayName, value: genre)
        }
        let button = DropdownFilterButton(items: items, title: "전체장르")
        return button
    }()
    
    private lazy var areaButton: DropdownFilterButton = {
        var items = [DropdownFilterButton.Item(title: "전체지역", value: "all")]
        items += AreaCode.allCases.map { area in
            DropdownFilterButton.Item(title: area.displayName, value: area)
        }
        let button = DropdownFilterButton(items: items, title: "전체지역")
        return button
    }()
    
    // MARK: - Public Observables
    var sortButtonTapped: Observable<SortType> {
        return sortButton.selectedValue
            .skip(1)
            .compactMap { $0 as? SortType }
    }
    
    var genreButtonTapped: Observable<GenreCode?> {
        return genreButton.selectedValue
            .skip(1)
            .map { value -> GenreCode? in
                if let genre = value as? GenreCode {
                    return genre
                } else if let stringValue = value as? String, stringValue == "all" {
                    return nil
                }
                return nil
            }
    }
    
    var areaButtonTapped: Observable<AreaCode?> {
        return areaButton.selectedValue
            .skip(1)
            .map { value -> AreaCode? in
                if let area = value as? AreaCode {
                    return area
                } else if let stringValue = value as? String, stringValue == "all" {
                    return nil
                }
                return nil
            }
    }
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        super.setupHierarchy()
        
        addSubview(containerView)
        
        containerView.addSubview(statisticsStackView)
        containerView.addSubview(dividerView)
        containerView.addSubview(filterStackView)
        
        [totalCountView, monthlyCountView].forEach {
            statisticsStackView.addArrangedSubview($0)
        }
        
        [sortButton, genreButton, areaButton].forEach {
            filterStackView.addArrangedSubview($0)
        }
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        statisticsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(statisticsStackView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        filterStackView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(32)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        backgroundColor = .ccBackground
    }
    
    // MARK: - Public Methods
    func configure(totalCount: Int, monthlyCount: Int) {
        totalCountView.updateCount(totalCount)
        monthlyCountView.updateCount(monthlyCount)
    }
}

// MARK: - StatisticsItemView
private final class StatisticsItemView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ccPrimary
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ccCaption1
        label.textColor = .ccSecondaryText
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .ccTitle2Bold
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    init(icon: UIImage?, title: String) {
        super.init(frame: .zero)
        
        iconImageView.image = icon
        titleLabel.text = title
        
        setupHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHierarchy() {
        addSubview(stackView)
        
        [iconImageView, titleLabel, countLabel].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
    }
    
    func updateCount(_ count: Int) {
        countLabel.text = "\(count)"
    }
}

//
//  FavoriteFilterCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class FavoriteFilterCell: BaseCollectionViewCell {
    
    // MARK: - Types
    enum SortType: String, CaseIterable {
        case latest = "최신순"
        case oldest = "오래된순"
        case nameAscending = "제목 오름차순"
        case nameDescending = "제목 내림차순"
    }
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - State Management
    private let currentSortTypeRelay = BehaviorRelay<SortType>(value: .latest)
    private let currentGenreRelay = BehaviorRelay<GenreCode?>(value: nil)
    private let currentAreaRelay = BehaviorRelay<AreaCode?>(value: nil)
    
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var sortButton: FilterButton = {
        let items = SortType.allCases.map { type in
            FilterButton.DropdownItem(title: type.rawValue, value: type)
        }
        let button = FilterButton(
            type: .dropdown(items: items),
            title: SortType.latest.rawValue
        )
        return button
    }()
    
    private lazy var genreButton: FilterButton = {
        var items = [FilterButton.DropdownItem(title: "전체장르", value: "all")]
        items += GenreCode.allCases.map { genre in
            FilterButton.DropdownItem(title: genre.displayName, value: genre)
        }
        let button = FilterButton(
            type: .dropdown(items: items),
            title: "전체장르"
        )
        return button
    }()
    
    private lazy var areaButton: FilterButton = {
        var items = [FilterButton.DropdownItem(title: "전체지역", value: "all")]
        items += AreaCode.allCases.map { area in
            FilterButton.DropdownItem(title: area.displayName, value: area)
        }
        let button = FilterButton(
            type: .dropdown(items: items),
            title: "전체지역"
        )
        return button
    }()
    
    // MARK: - Public Properties
    
    // 필터 상태를 담는 구조체
    struct FilterState {
        let sortType: SortType
        let genre: GenreCode?
        let area: AreaCode?
    }
    
    // 세 개의 필터 상태를 결합한 Observable
    var filterStateChanged: Observable<FilterState> {
        return Observable.combineLatest(
            currentSortTypeRelay.asObservable(),
            currentGenreRelay.asObservable(),
            currentAreaRelay.asObservable()
        )
        .skip(1) // 초기 결합값 (.latest, nil, nil)만 스킵
        .map { sortType, genre, area in
            FilterState(sortType: sortType, genre: genre, area: area)
        }
        .distinctUntilChanged { lhs, rhs in
            lhs.sortType == rhs.sortType &&
            lhs.genre?.rawValue == rhs.genre?.rawValue &&
            lhs.area?.rawValue == rhs.area?.rawValue
        }
    }
    
    // MARK: - Override Methods
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(stackView)
        
        [sortButton, genreButton, areaButton].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        bindButtons()
    }
    
    // MARK: - Binding
    private func bindButtons() {
        // 정렬 버튼 - skip 제거, 실제 선택만 받기
        sortButton.selectedValue
            .compactMap { $0 as? SortType }
            .bind(to: currentSortTypeRelay)
            .disposed(by: disposeBag)
        
        // 장르 버튼 - skip 제거, 실제 선택만 받기
        genreButton.selectedValue
            .map { value -> GenreCode? in
                if let genre = value as? GenreCode {
                    return genre
                } else if let stringValue = value as? String, stringValue == "all" {
                    return nil
                }
                return nil
            }
            .bind(to: currentGenreRelay)
            .disposed(by: disposeBag)
        
        // 지역 버튼 - skip 제거, 실제 선택만 받기
        areaButton.selectedValue
            .map { value -> AreaCode? in
                if let area = value as? AreaCode {
                    return area
                } else if let stringValue = value as? String, stringValue == "all" {
                    return nil
                }
                return nil
            }
            .bind(to: currentAreaRelay)
            .disposed(by: disposeBag)
    }
}

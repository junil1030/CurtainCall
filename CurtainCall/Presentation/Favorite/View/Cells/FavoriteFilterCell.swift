//
//  FavoriteFilterCell.swift
//  CurtainCall
//
//  Created by 서준일 on 10/2/25.
//

import UIKit
import RxSwift
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
    
    // MARK: - Subjects
    private let sortTypeSubject = PublishSubject<SortType>()
    private let genreSubject = PublishSubject<GenreCode?>()
    private let areaSubject = PublishSubject<AreaCode?>()
    
    // MARK: - Observables
    var sortType: Observable<SortType> {
        return sortTypeSubject.asObservable()
    }
    
    var selectedGenre: Observable<GenreCode?> {
        return genreSubject.asObservable()
    }
    
    var selectedArea: Observable<AreaCode?> {
        return areaSubject.asObservable()
    }
    
    // MARK: - Override Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        bindButtons()
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(sortButton)
        stackView.addArrangedSubview(genreButton)
        stackView.addArrangedSubview(areaButton)
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
        
        backgroundColor = .ccBackground
        bindButtons()
    }
    
    // MARK: - Binding
    private func bindButtons() {
        // 정렬 버튼
        sortButton.selectedValue
            .compactMap { $0 as? SortType }
            .bind(to: sortTypeSubject)
            .disposed(by: disposeBag)
        
        // 장르 버튼
        genreButton.selectedValue
            .map { value -> GenreCode? in
                if let genre = value as? GenreCode {
                    return genre
                } else if let stringValue = value as? String, stringValue == "all" {
                    return nil
                }
                return nil
            }
            .bind(to: genreSubject)
            .disposed(by: disposeBag)
        
        // 지역 버튼
        areaButton.selectedValue
            .map { value -> AreaCode? in
                if let area = value as? AreaCode {
                    return area
                } else if let stringValue = value as? String, stringValue == "all" {
                    return nil
                }
                return nil
            }
            .bind(to: areaSubject)
            .disposed(by: disposeBag)
    }
}

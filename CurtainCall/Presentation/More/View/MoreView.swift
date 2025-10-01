//
//  MoreView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit
import RxSwift
import SnapKit

final class MoreView: BaseView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let profileExperienceView = ProfileExperienceView()
    
    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "앱 정보"
        label.font = .ccTitle3Bold
        label.textColor = .ccPrimaryText
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ccBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 20)
        tableView.separatorColor = .ccSeparator
        tableView.isScrollEnabled = false
        tableView.rowHeight = 56
        tableView.register(MoreMenuCell.self, forCellReuseIdentifier: MoreMenuCell.identifier)
        return tableView
    }()
    
    // MARK: - Observables
    var menuItemSelected: Observable<MoreMenuItem> {
        return tableView.rx.itemSelected
            .map { indexPath in
                MoreMenuItem.allCases[indexPath.row]
            }
    }
    
    // MARK: - BaseView Override Methods
    override func setupHierarchy() {
        addSubview(profileExperienceView)
        addSubview(sectionTitleLabel)
        addSubview(tableView)
    }
    
    override func setupLayout() {
        profileExperienceView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(16)
            make.leading.equalTo(safeAreaLayoutGuide).inset(16).priority(.high)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(16).priority(.high)
        }
        
        sectionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileExperienceView.snp.bottom).offset(32)
            make.leading.equalTo(safeAreaLayoutGuide).inset(20).priority(.high)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20).priority(.high)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(sectionTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(56 * MoreMenuItem.allCases.count)
        }
    }
    override func setupStyle() {
        super.setupStyle()
        backgroundColor = .ccBackground
        setupTableView()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        Observable.just(MoreMenuItem.allCases)
            .bind(to: tableView.rx.items(
                cellIdentifier: MoreMenuCell.identifier,
                cellType: MoreMenuCell.self
            )) { index, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Methods
    func configure(with data: ProfileExperienceData) {
        profileExperienceView.configure(with: data)
    }
    
    func updateProfileImage(_ image: UIImage?) {
        profileExperienceView.updateProfileImage(image)
    }
}

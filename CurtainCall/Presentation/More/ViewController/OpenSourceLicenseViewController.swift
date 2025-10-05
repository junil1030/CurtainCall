//
//  OpenSourceLicenseViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

final class OpenSourceLicenseViewController: BaseViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ccBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.separatorColor = .ccSeparator
        tableView.rowHeight = 56
        tableView.register(OpenSourceLicenseCell.self, forCellReuseIdentifier: OpenSourceLicenseCell.identifier)
        return tableView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.title = "오픈소스 라이선스"
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        view.backgroundColor = .ccBackground
    }
    
    override func setupBind() {
        super.setupBind()
        
        // 라이브러리 리스트 바인딩
        Observable.just(OpenSourceLicense.libraries)
            .bind(to: tableView.rx.items(
                cellIdentifier: OpenSourceLicenseCell.identifier,
                cellType: OpenSourceLicenseCell.self
            )) { index, license, cell in
                cell.configure(with: license)
            }
            .disposed(by: disposeBag)
        
        // 셀 선택 시 Safari로 GitHub 열기
        tableView.rx.itemSelected
            .subscribe(with: self) { owner, indexPath in
                owner.tableView.deselectRow(at: indexPath, animated: true)
                let license = OpenSourceLicense.libraries[indexPath.row]
                
                guard let url = URL(string: license.url) else { return }
                let safariVC = SFSafariViewController(url: url)
                owner.present(safariVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

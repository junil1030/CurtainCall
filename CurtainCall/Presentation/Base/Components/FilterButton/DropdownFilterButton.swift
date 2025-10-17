//
//  DropdownFilterButton.swift
//  CurtainCall
//
//  Created by 서준일 on 10/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DropdownFilterButton: BaseFilterButton {
    
    // MARK: - Types
    struct Item {
        let title: String
        let value: Any
        
        init(title: String, value: Any) {
            self.title = title
            self.value = value
        }
    }
    
    // MARK: - Properties
    private let items: [Item]
    private var selectedTitle: String
    
    // MARK: - Init
    init(items: [Item], title: String) {
        self.items = items
        self.selectedTitle = title
        super.init(frame: .zero)
        
        updateTitle(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    override func getDefaultIcon() -> UIImage? {
        return UIImage(systemName: "chevron.down")
    }
    
    override func setupButtonAction() {
        rx.tap
            .subscribe(with: self) { owner, _ in
                owner.presentBottomSheet()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func presentBottomSheet() {
        guard let viewController = findViewController() else { return }
        
        let selectionItems = items.map { item in
            FilterBottomSheetViewController.SelectionItem(
                title: item.title,
                value: item.value
            )
        }
        
        let bottomSheet = FilterBottomSheetViewController(
            contentType: .selection(items: selectionItems)
        )
        
        bottomSheet.selection
            .take(1)
            .subscribe(with: self) { owner, value in
                owner.handleSelection(value)
            }
            .disposed(by: disposeBag)
        
        viewController.present(bottomSheet, animated: false)
    }
    
    private func handleSelection(_ value: Any) {
        // 선택된 값에 해당하는 타이틀 찾기
        if let selectedItem = items.first(where: { item in
            return String(describing: item.value) == String(describing: value)
        }) {
            selectedTitle = selectedItem.title
            updateTitle(selectedItem.title)
        }
        
        // 선택된 값 방출
        updateSelectedValue(value)
    }
    
    // MARK: - Helper Methods
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

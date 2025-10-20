//
//  DatePickerFilterButton.swift
//  CurtainCall
//
//  Created by 서준일 on 10/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DatePickerFilterButton: BaseFilterButton {
    
    // MARK: - Properties
    private let allowFuture: Bool
    private var selectedDate: Date
    
    // MARK: - Init
    init(allowFuture: Bool = false, initialDate: Date = Date().yesterday) {
        self.allowFuture = allowFuture
        self.selectedDate = initialDate
        super.init(frame: .zero)
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
        
        let bottomSheet = FilterBottomSheetViewController(
            contentType: .datePicker(allowFuture: allowFuture, initialDate: selectedDate)
        )
        
        bottomSheet.selection
            .take(1)
            .subscribe(with: self) { owner, value in
                if let date = value as? Date {
                    owner.handleSelection(date)
                }
            }
            .disposed(by: disposeBag)
        
        viewController.present(bottomSheet, animated: false)
    }
    
    private func handleSelection(_ date: Date) {
        selectedDate = date
        updateSelectedValue(date)
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

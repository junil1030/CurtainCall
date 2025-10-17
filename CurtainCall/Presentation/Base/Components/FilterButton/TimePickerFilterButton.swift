//
//  TimePickerFilterButton.swift
//  CurtainCall
//
//  Created by 서준일 on 10/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TimePickerFilterButton: BaseFilterButton {
    
    // MARK: - Properties
    private var selectedTime: Date
    
    // MARK: - Init
    init(initialTime: Date = Date()) {
        self.selectedTime = initialTime
        super.init(frame: .zero)
        
        updateTitle(formatTime(initialTime))
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
            contentType: .timePicker(initialTime: selectedTime)
        )
        
        bottomSheet.selection
            .take(1)
            .subscribe(with: self) { owner, value in
                if let time = value as? Date {
                    owner.handleSelection(time)
                }
            }
            .disposed(by: disposeBag)
        
        viewController.present(bottomSheet, animated: false)
    }
    
    private func handleSelection(_ time: Date) {
        selectedTime = time
        updateTitle(formatTime(time))
        updateSelectedValue(time)
    }
    
    private func formatTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
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

//
//  DateFormtter+Extension.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation

extension DateFormatter {
    
    // MARK: - Static Formatters
    static let kopisAPIFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
}

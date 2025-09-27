//
//  Logger.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    // MARK: - Categories
    static let network = Logger(subsystem: subsystem, category: "network")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    static let data = Logger(subsystem: subsystem, category: "data")
    static let config = Logger(subsystem: subsystem, category: "config")
}

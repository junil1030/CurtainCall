//
//  DeviceInfo.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import UIKit

enum DeviceInfo {
    
    // MARK: - Device Model
    static func getDeviceModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    // MARK: - Device OS
    static func getDeviceOS() -> String {
        let version = UIDevice.current.systemVersion
        return "iOS \(version)"
    }
    
    // MARK: - App Version
    static func getAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "알 수 없음"
        }
        return version
    }

}

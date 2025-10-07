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
        let model = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch model {
        // Simulator
        case "i386", "x86_64", "arm64":
            return "Simulator"
            
        // iPhone (초기)
        case "iPhone1,1":
            return "iPhone (1st generation)"
        case "iPhone1,2":
            return "iPhone 3G"
        case "iPhone2,1":
            return "iPhone 3GS"
            
        // iPhone 4 계열
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            return "iPhone 4"
        case "iPhone4,1":
            return "iPhone 4s"
            
        // iPhone 5 계열
        case "iPhone5,1", "iPhone5,2":
            return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":
            return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":
            return "iPhone 5s"
            
        // iPhone 6 / SE (1세대)
        case "iPhone7,2":
            return "iPhone 6"
        case "iPhone7,1":
            return "iPhone 6 Plus"
        case "iPhone8,4":
            return "iPhone SE (1st generation)"
            
        // iPhone 6s / 6s Plus
        case "iPhone8,1":
            return "iPhone 6s"
        case "iPhone8,2":
            return "iPhone 6s Plus"
            
        // iPhone 7 / 7 Plus
        case "iPhone9,1", "iPhone9,3":
            return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":
            return "iPhone 7 Plus"
            
        // iPhone 8 / 8 Plus / X 계열
        case "iPhone10,1", "iPhone10,4":
            return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":
            return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":
            return "iPhone X"
            
        // iPhone XR / XS / XS Max 계열
        case "iPhone11,2":
            return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":
            return "iPhone XS Max"
        case "iPhone11,8":
            return "iPhone XR"
            
        // iPhone 11 계열
        case "iPhone12,1":
            return "iPhone 11"
        case "iPhone12,3":
            return "iPhone 11 Pro"
        case "iPhone12,5":
            return "iPhone 11 Pro Max"
            
        // iPhone SE (2세대) / iPhone 12 계열
        case "iPhone12,8":
            return "iPhone SE (2nd generation)"
        case "iPhone13,1":
            return "iPhone 12 mini"
        case "iPhone13,2":
            return "iPhone 12"
        case "iPhone13,3":
            return "iPhone 12 Pro"
        case "iPhone13,4":
            return "iPhone 12 Pro Max"
            
        // iPhone 13 계열
        case "iPhone14,4":
            return "iPhone 13 mini"
        case "iPhone14,5":
            return "iPhone 13"
        case "iPhone14,2":
            return "iPhone 13 Pro"
        case "iPhone14,3":
            return "iPhone 13 Pro Max"
            
        // iPhone SE (3세대) / iPhone 14 계열
        case "iPhone14,6":
            return "iPhone SE (3rd generation)"
        case "iPhone14,7":
            return "iPhone 14"
        case "iPhone14,8":
            return "iPhone 14 Plus"
        case "iPhone15,2":
            return "iPhone 14 Pro"
        case "iPhone15,3":
            return "iPhone 14 Pro Max"
            
        // iPhone 15 계열
        case "iPhone15,4":
            return "iPhone 15"
        case "iPhone15,5":
            return "iPhone 15 Plus"
        case "iPhone16,1":
            return "iPhone 15 Pro"
        case "iPhone16,2":
            return "iPhone 15 Pro Max"
            
        // iPhone 16 계열
        case "iPhone17,3":
            return "iPhone 16"
        case "iPhone17,4":
            return "iPhone 16 Plus"
        case "iPhone17,1":
            return "iPhone 16 Pro"
        case "iPhone17,2":
            return "iPhone 16 Pro Max"
        case "iPhone17,5":
            return "iPhone 16e"  // 변형 모델 (e 버전) — 최신 목록 기준 참고됨 :contentReference[oaicite:0]{index=0}
            
        // iPhone 17 계열
        case "iPhone18,3":
            return "iPhone 17"
        case "iPhone18,1":
            return "iPhone 17 Pro"
        case "iPhone18,2":
            return "iPhone 17 Pro Max"
        case "iPhone18,4":
            return "iPhone Air"

        default:
            return model  // 모르는 식별자는 그대로 반환하거나 “Unknown” 등 처리
        }
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

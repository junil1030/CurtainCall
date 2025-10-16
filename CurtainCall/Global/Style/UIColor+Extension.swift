//
//  UIColor+Extension.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit

extension UIColor {
    //MARK: - Primary Colors
    // cc접두사: CurtainCall 줄임말
    
    /// 메인 퍼스널 컬러 #9A0D17
    static let ccPrimary = UIColor(red: 154/255, green: 13/255, blue: 23/255, alpha: 1.0)
    
    /// 보조 컬러 #F2C6A0
    static let ccSecondary = UIColor(red: 242/255, green: 198/255, blue: 160/255, alpha: 1.0)
    
    /// 강조 컬러 - #E94E3C
    static let ccAccent = UIColor(red: 233/255, green: 78/255, blue: 60/255, alpha: 1.0)
    
    // MARK: - Background Colors
    /// 메인 배경 (흰색)
    static let ccBackground = UIColor.systemBackground
    
    /// 구분선 배경
    static let ccSeparator = UIColor.systemGray4
    
    /// 비활성화 배경
    static let ccDisabledBackground = UIColor.systemGray5
    
    // MARK: - Text Colors
    /// 메인 텍스트 (검정)
    static let ccPrimaryText = UIColor.label
    
    /// 보조 텍스트 (회색)
    static let ccSecondaryText = UIColor.secondaryLabel
    
    /// 강조 텍스트 (브랜드 컬러)
    static let ccAccentText = UIColor.ccPrimary
    
    /// 비활성화 텍스트
    static let ccDisabledText = UIColor.systemGray3
    
    /// 버튼 위 텍스트 (흰색)
    static let ccButtonText = UIColor.white
    
    /// 배너 텍스트 (흰색)
    static let ccBannerText = UIColor.white
    
    // MARK: - Button Colors
    /// 활성화 버튼 배경
    static let ccButtonBackground = UIColor.ccPrimary
    
    /// 눌린 버튼 배경
    static let ccButtonPressed = UIColor.ccAccent
    
    /// 비활성화 버튼 배경
    static let ccButtonDisabled = UIColor.ccDisabledBackground
    
    /// 보조 버튼 배경 (테두리만 있는 버튼용)
    static let ccSecondaryButton = UIColor.clear
    
    /// 보조 버튼 테두리
    static let ccSecondaryButtonBorder = UIColor.ccPrimary
    
    // MARK: - Tab Bar Colors
    /// 선택된 탭 아이템
    static let ccTabSelected = UIColor.ccPrimary
    
    /// 선택되지 않은 탭 아이템
    static let ccTabUnselected = UIColor.systemGray2
    
    // MARK: - Navigation Colors
    /// 네비게이션 틴트 컬러
    static let ccNavigationTint = UIColor.ccPrimary
    
    // MARK: - System Status Colors
    /// 성공 상태
    static let ccSuccess = UIColor.systemGreen
    
    /// 경고 상태
    static let ccWarning = UIColor.systemYellow
    
    /// 에러 상태
    static let ccError = UIColor.systemRed
    
    /// 정보 상태
    static let ccInfo = UIColor.systemBlue
    
    // MARK: - Genre Chart Colors
    // 뮤지컬
    static let ccMusicalChart = UIColor(red: 165/255, green: 30/255, blue: 46/255, alpha: 1.0)
    
    // 연극
    static let ccPlayChart = UIColor(red: 179/255, green: 34/255, blue: 52/255, alpha: 1.0)
    
    // 대중음악
    static let ccPopularMusicChart = UIColor(red: 194/255, green: 42/255, blue: 54/255, alpha: 1.0)
    
    // 서커스/마술
    static let ccCircus_MagicChart = UIColor(red: 207/255, green: 58/255, blue: 69/255, alpha: 1.0)
    
    // 클래식
    static let ccClassicChart = UIColor(red: 216/255, green: 76/255, blue: 83/255, alpha: 1.0)
    
    // 무용
    static let ccDanceChart = UIColor(red: 225/255, green: 94/255, blue: 97/255, alpha: 1.0)
    
    // 복합
    static let ccComplexChart = UIColor(red: 235/255, green: 111/255, blue: 111/255, alpha: 1.0)
    
    // 기타
    static let ccSomeChart = UIColor(red: 242/255, green: 127/255, blue: 125/255, alpha: 1.0)
}

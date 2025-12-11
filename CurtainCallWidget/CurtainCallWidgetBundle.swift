//
//  CurtainCallWidgetBundle.swift
//  CurtainCallWidget
//
//  Created by 서준일 on 12/8/25.
//

import WidgetKit
import SwiftUI

@main
struct CurtainCallWidgetBundle: WidgetBundle {
    var body: some Widget {
        CurtainCallWidget()

        // iOS 16+ 잠금 화면 위젯
        if #available(iOS 16.0, *) {
            CurtainCallLockScreenWidget()
        }

        // iOS 16.2+ Live Activity
        if #available(iOS 16.2, *) {
            PerformanceLiveActivity()
        }
    }
}

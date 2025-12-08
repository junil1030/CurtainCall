//
//  DeepLinkHandler.swift
//  CurtainCall
//
//  Created by 서준일 on 12/8/25.
//

import Foundation
import UIKit
import OSLog

/// Deep Link 처리 핸들러
final class DeepLinkHandler {
    // MARK: - Singleton
    
    static let shared = DeepLinkHandler()
    
    // MARK: - Properties

    private weak var window: UIWindow?
    private var pendingDeepLink: WidgetDeepLink?

    // MARK: - Initialization

    private init() { }

    // MARK: - Public Methods

    /// Window 설정
    func configure(window: UIWindow?) {
        self.window = window
    }

    /// Deep Link 처리
    func handle(url: URL) {
        guard let deepLink = WidgetDeepLink.from(url: url) else {
            Logger.config.warning("잘못된 Deep Link: \(url.absoluteString)")
            return
        }

        Logger.config.info("Deep Link 처리: \(url.absoluteString)")

        // pending link로 저장
        pendingDeepLink = deepLink

        // 약간의 딜레이 후 처리 (ViewController가 준비될 시간 확보)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.executeDeepLink(deepLink)
        }
    }

    /// Pending Deep Link 확인 및 처리 (ViewController의 viewDidAppear에서 호출)
    func checkPendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }

        Logger.config.debug("Pending Deep Link 처리")
        executeDeepLink(deepLink)
        pendingDeepLink = nil
    }
    
    // MARK: - Private Methods

    /// Deep Link 실행
    private func executeDeepLink(_ deepLink: WidgetDeepLink) {
        switch deepLink {
        case .home:
            navigateToHome()

        case .favorites:
            navigateToFavorites()

        case .records:
            navigateToRecords()

        case .performanceDetail(let id):
            navigateToPerformanceDetail(id: id)
        }
    }

    /// 홈으로 이동
    private func navigateToHome() {
        // 이미 홈 화면이므로 아무것도 하지 않음
        Logger.config.debug("홈 화면으로 이동")
    }
    
    /// 즐겨찾기 화면으로 이동
    private func navigateToFavorites() {
        // NotificationCenter로 이벤트 전달하여 홈 화면에서 즐겨찾기 버튼 동작 실행
        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToFavorites"),
            object: nil
        )
        Logger.config.debug("즐겨찾기 화면 이동 요청")
    }
    
    /// 관람 기록 화면으로 이동
    private func navigateToRecords() {
        guard let window = window,
              let rootVC = window.rootViewController else {
            return
        }
        
        if let tabBarController = findTabBarController(from: rootVC) {
            // 관람 기록 탭 인덱스
            tabBarController.selectedIndex = 2
            Logger.config.debug("관람 기록 탭으로 이동")
        }
        Logger.config.debug("관람 기록 화면 이동 요청")
    }
    
    /// 공연 상세 화면으로 이동
    private func navigateToPerformanceDetail(id: String) {
        // NotificationCenter로 이벤트 전달하여 현재 화면에서 처리하도록
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowPerformanceDetail"),
            object: nil,
            userInfo: ["performanceId": id]
        )
        Logger.config.debug("공연 상세 화면 이동 요청: \(id)")
    }
    
    /// TabBarController 찾기
    private func findTabBarController(from viewController: UIViewController) -> UITabBarController? {
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }
        
        for child in viewController.children {
            if let found = findTabBarController(from: child) {
                return found
            }
        }
        return nil
    }
}

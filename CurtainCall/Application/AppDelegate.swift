//
//  AppDelegate.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit
import OSLog
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        configureRealm()
        configureFirebase()
        application.registerForRemoteNotifications()

        // Widget 데이터 초기 업데이트
        WidgetDataManager.shared.updateWidgetData()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let container = DIContainer.shared
        let realmProvider = container.resolve(RealmProvider.self)
        realmProvider.compact()
        Logger.config.info("Realm DB 압축 및 앱 종료")
    }
    
    // MARK: - Remote Notifications (APNs)
    
    // 토큰 등록 성공
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // APNs 토큰을 Firebase에 전달
        Messaging.messaging().apnsToken = deviceToken
        
        #if DEBUG
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Logger.config.info("APNs Device Token: \(token)")
        #endif
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        Logger.config.error("APNs 등록 실패: \(error.localizedDescription)")
    }


    // MARK: - Private Methods
    private func configureRealm() {
        Logger.config.info("Realm 설정")
        
        do {
            let container = DIContainer.shared
            let realmProvider = container.resolve(RealmProvider.self)
            
            try realmProvider.initializeDefaultUser()
            
            #if DEBUG
            realmProvider.printDebugInfo()
            #endif
            
            Logger.config.info("Realm 설정 완료")
        } catch {
            Logger.config.error("Realm 설정 실패: \(error.localizedDescription)")
        }
    }
    
    private func configureFirebase() {
        Logger.config.info("Firebase 설정")
        
        FirebaseApp.configure()
        
        // Delegate 설정
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // 알림 권한 요청
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions
        ) { granted, error in
            if let error = error {
                Logger.config.error("알림 권한 요청 실패: \(error.localizedDescription)")
            } else {
                Logger.config.info("알림 권한: \(granted ? "허용" : "거부")")
            }
        }
        
        Logger.config.info("Firebase 설정 완료")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 포그라운드에서 알림 수신 시 호출
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        
        #if DEBUG
        Logger.config.info("포그라운드 알림 수신: \(userInfo)")
        #endif
        
        // 포그라운드에서도 배너, 사운드, 뱃지 표시
        completionHandler([.banner, .sound, .badge])
    }
    
    // 알림 탭 시 호출
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        #if DEBUG
        Logger.config.info("알림 탭: \(userInfo)")
        #endif
        
        // TODO: 알림 타입에 따른 화면 전환 처리
        handleNotificationResponse(userInfo)
        
        completionHandler()
    }
    
    // 알림 응답 처리
    private func handleNotificationResponse(_ userInfo: [AnyHashable: Any]) {
        // 알림 페이로드에서 필요한 정보 추출
        // 예: 공연 ID, 딥링크 등
        
        // 예시:
        // if let performanceId = userInfo["performance_id"] as? String {
        //     // 해당 공연 상세 화면으로 이동
        // }
        
        print(#function)
    }

}

extension AppDelegate: MessagingDelegate {
    
    // FCM 토큰 갱신 시 호출
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let fcmToken = fcmToken else {
            Logger.config.warning("FCM 토큰이 nil입니다")
            return
        }
        
        Logger.config.info("FCM 토큰 갱신: \(fcmToken)")
        
        // 토큰을 서버에 전송하거나 저장
        saveFCMToken(fcmToken)
        
        // NotificationCenter를 통해 앱 내부에 토큰 전달
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
    
    // FCM 토큰 저장
    private func saveFCMToken(_ token: String) {
        // UserDefaults에 저장
        UserDefaults.standard.set(token, forKey: "FCMToken")
        
        // TODO: 서버에 토큰 전송
        // NetworkService.shared.updateFCMToken(token)
    }
}

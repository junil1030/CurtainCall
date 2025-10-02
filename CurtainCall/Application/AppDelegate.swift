//
//  AppDelegate.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit
import OSLog

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureRealm()
        
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
        RealmManager.shared.compact()
        Logger.config.info("Realm DB 압축 및 앱 종료")
    }


    // MARK: - Private Methods
    private func configureRealm() {
        Logger.config.info("Realm 설정")
        
        do {
            _ = RealmManager.shared
            
            try RealmManager.shared.initializeDefaultUser()
            
            #if DEBUG
            RealmManager.shared.printDebugInfo()
            #endif
            
            Logger.config.info("Realm 설정 완료")
        } catch {
            Logger.config.error("Realm 설정 실패: \(error.localizedDescription)")
        }
    }
}


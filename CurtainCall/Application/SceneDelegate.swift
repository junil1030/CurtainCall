//
//  SceneDelegate.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let mainTabBarController = MainTabBarController()
        window?.rootViewController = mainTabBarController
        window?.makeKeyAndVisible()
        
        #if DEBUG
        seedDummyViewingRecordsIfNeeded()
        #endif
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    private func seedDummyViewingRecordsIfNeeded() {
        let realm = try! Realm()
        
        // 이미 데이터가 있으면 skip
        if realm.objects(ViewingRecord.self).isEmpty == false {
            return
        }
        
        let titles = [
            "레미제라블", "햄릿", "오페라의 유령", "위키드", "맘마미아",
            "노트르담 드 파리", "캣츠", "지킬앤하이드", "아이다", "라이온킹"
        ]
        
        let posters = [
            "https://example.com/poster1.jpg",
            "https://example.com/poster2.jpg",
            "https://example.com/poster3.jpg"
        ]
        
        let areas = AreaCode.allCases.map { $0.displayName }
        let genres = GenreCode.allCases.map { $0.displayName }
        let locations = ["블루스퀘어", "세종문화회관", "샤롯데씨어터", "LG아트센터"]
        let companions = ["혼자", "친구", "가족", "연인"]
        let casts = ["홍길동", "김철수", "이영희", "박보검", "아이유"]
        
        try! realm.write {
            for i in 1...500 {
                let record = ViewingRecord()
                record.performanceId = UUID().uuidString
                record.title = titles.randomElement()!
                record.posterURL = posters.randomElement()!
                record.area = areas.randomElement()!
                record.location = locations.randomElement()!
                record.genre = genres.randomElement()!
                record.viewingDate = Date().addingTimeInterval(Double.random(in: -60*60*24*365 ... 0))
                record.rating = Int.random(in: 0...5)
                record.seat = "R석 \(Int.random(in: 1...30))열 \(Int.random(in: 1...50))번"
                record.companion = companions.randomElement()!
                record.cast = casts.shuffled().prefix(Int.random(in: 1...3)).joined(separator: ", ")
                record.memo = "감상평 예시 \(i)"
                record.createdAt = Date()
                record.updatedAt = Date()
                
                realm.add(record)
            }
        }
    }
}


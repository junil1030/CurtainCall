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
    
    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        // Unit test host 앱 실행 시 네트워크/DI 초기화 부작용을 차단한다.
        if isRunningTests {
            window?.rootViewController = UIViewController()
            window?.makeKeyAndVisible()
            return
        }

        let mainTabBarController = MainTabBarController()
        window?.rootViewController = mainTabBarController
        window?.makeKeyAndVisible()

        // DeepLinkHandler에 window 설정
        DeepLinkHandler.shared.configure(window: window)

        // URL Context가 있으면 Deep Link 처리
        if let urlContext = connectionOptions.urlContexts.first {
            DeepLinkHandler.shared.handle(url: urlContext.url)
        }

        #if DEBUG
        if !isRunningTests {
            seedDummyViewingRecordsIfNeeded()
        }
        #endif
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Widget에서 앱을 열 때 호출됨
        guard let url = URLContexts.first?.url else { return }
        DeepLinkHandler.shared.handle(url: url)
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
        let container = DIContainer.shared
        let realmProvider = container.resolve(RealmProvider.self)
        let networkManager = container.resolve(NetworkManagerProtocol.self)
        
        do {
            let realm = try realmProvider.realm()
            
            // 이미 데이터가 있으면 skip
            if realm.objects(ViewingRecord.self).isEmpty == false {
                return
            }
            
            // API에서 실제 공연 데이터 가져오기
            Task {
                do {
                    let startDate = "20251201"
                    let endDate = "20251230"
                    
                    // API 호출
                    let response = try await networkManager.request(
                        .searchPerformance(
                            startDate: startDate,
                            endDate: endDate,
                            page: "1",
                            keyword: "",
                            area: nil,
                            rows: 100
                        ),
                        responseType: SearchResponseDTO.self
                    )
                    
                    let performances = response.dbs.db
                    
                    // 실제 데이터를 기반으로 더미 관람 기록 생성
                    await MainActor.run {
                        self.createViewingRecords(from: performances, realmProvider: realmProvider)
                    }
                    
                } catch {
                    print("더미 데이터 생성 실패: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Realm 접근 실패: \(error.localizedDescription)")
        }
    }
    
    private func createViewingRecords(from performances: [SearchItemDTO], realmProvider: RealmProvider) {
        let companions = ["혼자", "친구", "가족", "연인"]
        let casts = ["홍길동", "김철수", "이영희", "박보검", "아이유"]
        
        // 날짜 범위 설정
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 10, day: 29))!
        let timeInterval = endDate.timeIntervalSince(startDate)
        
        do {
            let realm = try realmProvider.realm()
            try realm.write {
                // API에서 받은 데이터만큼 (최대 100개) 관람 기록 생성
                for performance in performances {
                    let record = ViewingRecord()
                    
                    // 실제 API 데이터 사용
                    record.performanceId = performance.mt20id
                    record.title = performance.prfnm
                    record.posterURL = performance.poster ?? ""
                    record.location = performance.fcltynm ?? "공연장 정보 없음"
                    record.genre = convertToGenreCode(performance.genrenm ?? "")
                    record.area = performance.area ?? "지역 정보 없음"
                    
                    // 더미 데이터 (랜덤 생성)
                    let randomDate = startDate.addingTimeInterval(Double.random(in: 0...timeInterval))
                    record.viewingDate = randomDate
                    record.rating = Int.random(in: 0...5)
                    record.seat = "R석 \(Int.random(in: 1...30))열 \(Int.random(in: 1...50))번"
                    record.companion = companions.randomElement()!
                    record.cast = casts.shuffled().prefix(Int.random(in: 1...3)).joined(separator: ", ")
                    record.memo = "\(performance.prfnm)의 관람 후기입니다."
                    record.createdAt = randomDate
                    record.updatedAt = randomDate + 1
                    
                    realm.add(record)
                }
                
                print("✅ 더미 데이터 \(performances.count)개 생성 완료")
            }
        } catch {
            print("더미 데이터 생성 중 Realm 오류: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Genre Code Conversion
    
    // DisplayName 또는 Code를 받아서 Code로 변환 (마이그레이션 방식 동일)
    private func convertToGenreCode(_ value: String) -> String {
        guard !value.isEmpty else { return "" }
        
        // 1. 이미 Code 형식인지 확인
        if GenreCode(rawValue: value) != nil {
            return value
        }
        
        // 2. 괄호 제거한 버전으로 매칭 시도
        let cleanedValue = removeParenthesesContent(from: value)
        if let genreCode = GenreCode.from(displayName: cleanedValue) {
            return genreCode.rawValue
        }
        
        // 3. 원본으로도 한번 더 시도 (이미 괄호가 없는 경우)
        if let genreCode = GenreCode.from(displayName: value) {
            return genreCode.rawValue
        }
        
        // 4. 변환 실패 시 원본 반환
        print("⚠️ 알 수 없는 장르 값: \(value)")
        return value
    }
    
    // 괄호와 괄호 안의 내용 제거
    private func removeParenthesesContent(from text: String) -> String {
        return text.replacingOccurrences(of: "\\([^)]*\\)", with: "", options: .regularExpression)
    }
}

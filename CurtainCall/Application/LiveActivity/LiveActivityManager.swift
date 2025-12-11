//
//  LiveActivityManager.swift
//  CurtainCall
//
//  Created by 서준일 on 12/9/25.
//

import Foundation
import ActivityKit
import OSLog
import RealmSwift

/// Live Activity 관리 매니저 (Main App 전용)
@available(iOS 16.2, *)
final class LiveActivityManager {

    // MARK: - Singleton
    static let shared = LiveActivityManager()

    // MARK: - Properties
    private var currentActivity: Activity<PerformanceActivityAttributes>?

    // MARK: - Initialization
    private init() {}

    // MARK: - Public Methods

    /// Realm에서 즐겨찾기 목록을 가져와 Live Activity 시작/업데이트
    func refreshLiveActivityFromRealm() {
        let container = DIContainer.shared
        let realmProvider = container.resolve(RealmProvider.self)

        guard let realm = try? realmProvider.realm() else {
            Logger.config.error("Realm 초기화 실패")
            return
        }

        let favoriteObjects = realm.objects(FavoritePerformance.self)
            .sorted(byKeyPath: "createdAt", ascending: false)

        let favorites = favoriteObjects.map { obj -> WidgetPerformance in
            return WidgetPerformance(
                id: obj.id,
                title: obj.title,
                facility: obj.location,
                poster: obj.posterURL,
                startDate: obj.startDate,
                endDate: obj.endDate,
                genre: obj.genre
            )
        }

        if favorites.isEmpty {
            endCurrentLiveActivity()
        } else {
            updateLiveActivity(with: Array(favorites))
        }
    }

    /// 현재 실행 중인 Live Activity 종료
    func endCurrentLiveActivity() {
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            Logger.config.debug("Live Activity 종료")
        }
    }

    // MARK: - Private Methods

    /// 즐겨찾기 목록에서 우선순위가 가장 높은 공연을 Live Activity로 시작
    private func startLiveActivity(with favorites: [WidgetPerformance]) {
        // 이미 실행 중인 Live Activity가 있으면 종료
        endCurrentLiveActivity()

        // 우선순위 공연 선택
        guard let selectedPerformance = selectPriorityPerformance(from: favorites) else {
            Logger.config.debug("Live Activity 시작 실패: 우선순위 공연 없음")
            return
        }

        // Live Activity 시작
        do {
            let attributes = createAttributes(from: selectedPerformance)
            let contentState = createContentState(
                from: selectedPerformance,
                totalFavorites: favorites.count
            )

            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )

            currentActivity = activity
            Logger.config.info("Live Activity 시작: \(selectedPerformance.title)")

        } catch {
            Logger.config.error("Live Activity 시작 실패: \(error.localizedDescription)")
        }
    }

    /// 현재 실행 중인 Live Activity 업데이트
    private func updateLiveActivity(with favorites: [WidgetPerformance]) {
        guard let activity = currentActivity else {
            // Live Activity가 없으면 새로 시작
            startLiveActivity(with: favorites)
            return
        }

        // 우선순위 공연 선택
        guard let selectedPerformance = selectPriorityPerformance(from: favorites) else {
            // 우선순위 공연이 없으면 종료
            endCurrentLiveActivity()
            return
        }

        // 현재 Live Activity와 다른 공연이 선택되면 재시작
        if activity.attributes.performanceId != selectedPerformance.id {
            startLiveActivity(with: favorites)
            return
        }

        // 같은 공연이면 상태만 업데이트
        Task {
            let contentState = createContentState(
                from: selectedPerformance,
                totalFavorites: favorites.count
            )
            await activity.update(.init(state: contentState, staleDate: nil))
            Logger.config.debug("Live Activity 업데이트: \(selectedPerformance.title)")
        }
    }

    /// 우선순위가 가장 높은 공연 선택
    /// 우선순위: 1) 종료 안 된 공연 2) 시작일이 가까운 공연 3) 최근 즐겨찾기 추가
    private func selectPriorityPerformance(from favorites: [WidgetPerformance]) -> WidgetPerformance? {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        return favorites
            .compactMap { performance -> (performance: WidgetPerformance, endDate: Date)? in
                guard let endDate = dateFormatter.date(from: performance.endDate) else {
                    return nil
                }
                return (performance, endDate)
            }
            .filter { $0.endDate >= today } // 종료 안 된 공연만
            .sorted { item1, item2 in
                // 시작일 파싱
                guard let startDate1 = dateFormatter.date(from: item1.performance.startDate),
                      let startDate2 = dateFormatter.date(from: item2.performance.startDate) else {
                    return false
                }

                // D-Day 계산 (절대값으로 비교)
                let dday1 = abs(Calendar.current.dateComponents([.day], from: today, to: startDate1).day ?? 0)
                let dday2 = abs(Calendar.current.dateComponents([.day], from: today, to: startDate2).day ?? 0)

                // D-Day가 같으면 ID로 비교 (일관성 유지)
                if dday1 == dday2 {
                    return item1.performance.id < item2.performance.id
                }

                return dday1 < dday2
            }
            .first?
            .performance
    }

    /// WidgetPerformance에서 ActivityAttributes 생성
    private func createAttributes(from performance: WidgetPerformance) -> PerformanceActivityAttributes {
        return PerformanceActivityAttributes(
            performanceId: performance.id,
            title: performance.title,
            facility: performance.facility,
            startDate: performance.startDate,
            endDate: performance.endDate,
            genre: performance.genre
        )
    }

    /// WidgetPerformance에서 ContentState 생성
    private func createContentState(
        from performance: WidgetPerformance,
        totalFavorites: Int
    ) -> PerformanceActivityAttributes.ContentState {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        let today = Date()

        guard let startDate = dateFormatter.date(from: performance.startDate),
              let endDate = dateFormatter.date(from: performance.endDate) else {
            // 날짜 파싱 실패 시 기본값
            return PerformanceActivityAttributes.ContentState(
                dDay: 0,
                remainingDays: 0,
                isStarted: false,
                favoriteCount: totalFavorites
            )
        }

        let calendar = Calendar.current

        // D-Day 계산
        let dDayComponents = calendar.dateComponents([.day], from: today, to: startDate)
        let dDay = dDayComponents.day ?? 0

        // 공연 시작 여부
        let isStarted = today >= startDate && today <= endDate

        // 종료까지 남은 일수
        let remainingComponents = calendar.dateComponents([.day], from: today, to: endDate)
        let remainingDays = max(0, remainingComponents.day ?? 0)

        return PerformanceActivityAttributes.ContentState(
            dDay: dDay,
            remainingDays: remainingDays,
            isStarted: isStarted,
            favoriteCount: totalFavorites
        )
    }
}

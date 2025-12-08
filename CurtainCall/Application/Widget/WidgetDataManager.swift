//
//  WidgetDataManager.swift
//  CurtainCall
//
//  Created by 서준일 on 12/8/25.
//

import Foundation
import RealmSwift
import WidgetKit
import OSLog

/// 메인 앱에서 Widget 데이터를 수집하는 매니저
final class WidgetDataManager {
    // MARK: - Singleton

    static let shared = WidgetDataManager()

    // MARK: - Initialization

    private init() { }

    // MARK: - Public Methods

    /// Realm에서 데이터를 수집하고 Widget 캐시 업데이트
    func updateWidgetData() {
        do {
            let realm = try Realm()

            // 즐겨찾기 공연 가져오기 (최대 5개)
            let favorites = realm.objects(FavoritePerformance.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
                .prefix(5)
                .map { favorite -> WidgetPerformance in
                    WidgetPerformance(
                        id: favorite.id,
                        title: favorite.title,
                        facility: favorite.location,
                        poster: favorite.posterURL,
                        startDate: favorite.startDate,
                        endDate: favorite.endDate,
                        genre: favorite.genre
                    )
                }

            // 통계 계산
            let statistics = calculateStatistics(realm: realm)

            let widgetData = WidgetData(
                favoritePerformances: Array(favorites),
                statistics: statistics,
                lastUpdated: Date()
            )

            // WidgetDataProvider를 통해 캐시에 저장
            WidgetDataProvider.shared.saveWidgetData(widgetData)

            // Widget 새로고침
            reloadAllWidgets()

            Logger.data.info("Widget 데이터 업데이트 완료")
        } catch {
            Logger.data.error("Widget 데이터 수집 실패: \(error.localizedDescription)")
        }
    }

    /// 모든 Widget 새로고침
    func reloadAllWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
        Logger.data.debug("Widget 새로고침 요청")
    }

    // MARK: - Private Methods

    /// 통계 계산
    private func calculateStatistics(realm: Realm) -> WidgetStatistics {
        let favorites = realm.objects(FavoritePerformance.self)
        let records = realm.objects(ViewingRecord.self)

        // 가장 많이 본 장르
        let genreCounts = Dictionary(grouping: records, by: { $0.genre })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }

        let mostViewedGenreCode = genreCounts.first?.key
        let mostViewedGenre = mostViewedGenreCode.flatMap { GenreCode(rawValue: $0) }?.displayName

        // 올해 관람한 공연 수
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let thisYearCount = records.filter { record in
            let year = calendar.component(.year, from: record.viewingDate)
            return year == currentYear
        }.count

        return WidgetStatistics(
            favoriteCount: favorites.count,
            recordCount: records.count,
            mostViewedGenre: mostViewedGenre,
            thisYearCount: thisYearCount
        )
    }
}

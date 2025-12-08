//
//  WidgetDataProvider.swift
//  CurtainCall
//
//  Created by 서준일 on 12/8/25.
//

import Foundation
import OSLog

/// Widget 데이터를 제공하는 클래스 (캐시 읽기/쓰기만 담당)
final class WidgetDataProvider {
    // MARK: - Singleton

    static let shared = WidgetDataProvider()

    // MARK: - Initialization

    private init() { }

    // MARK: - Public Methods

    /// Widget 데이터를 캐시에 저장 (메인 앱에서 호출)
    func saveWidgetData(_ data: WidgetData) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(data)

            SharedUserDefaults.shared.set(encoded, forKey: .widgetDataCache)
            SharedUserDefaults.shared.setDate(Date(), forKey: .lastWidgetUpdate)
            SharedUserDefaults.shared.synchronize()

            Logger.data.info("Widget 데이터 캐싱 완료")
        } catch {
            Logger.data.error("Widget 데이터 인코딩 실패: \(error.localizedDescription)")
        }
    }

    /// 캐시된 Widget 데이터 가져오기 (Widget Extension에서 호출)
    func getCachedWidgetData() -> WidgetData {
        guard let cached: Data = SharedUserDefaults.shared.get(forKey: .widgetDataCache) else {
            Logger.data.warning("캐시된 Widget 데이터 없음")
            return emptyWidgetData()
        }

        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(WidgetData.self, from: cached)
            return decoded
        } catch {
            Logger.data.error("Widget 데이터 디코딩 실패: \(error.localizedDescription)")
            return emptyWidgetData()
        }
    }

    /// 마지막 업데이트 시간 가져오기
    func getLastUpdateDate() -> Date? {
        return SharedUserDefaults.shared.getDate(forKey: .lastWidgetUpdate)
    }

    /// 빈 Widget 데이터 생성 (placeholder용)
    func emptyWidgetData() -> WidgetData {
        return WidgetData(
            favoritePerformances: [],
            statistics: WidgetStatistics(
                favoriteCount: 0,
                recordCount: 0,
                mostViewedGenre: nil,
                thisYearCount: 0
            ),
            lastUpdated: Date()
        )
    }
}

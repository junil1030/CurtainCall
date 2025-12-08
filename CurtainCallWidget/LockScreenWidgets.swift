//
//  LockScreenWidgets.swift
//  CurtainCallWidget
//
//  Created by 서준일 on 12/8/25.
//

import SwiftUI
import WidgetKit

// MARK: - Circular Widget (원형)
struct CircularWidgetView: View {
    let data: WidgetData

    var body: some View {
        VStack(spacing: 2) {
            Text("\(data.statistics.favoriteCount)")
                .font(.title2)
                .bold()
            Text("즐겨찾기")
                .font(.caption2)
        }
        .widgetLabel {
            Text("즐겨찾기")
        }
    }
}

// MARK: - Rectangular Widget (직사각형)
struct RectangularWidgetView: View {
    let data: WidgetData

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                if let firstFavorite = data.favoritePerformances.first {
                    Text(firstFavorite.title)
                        .font(.headline)
                        .lineLimit(1)

                    Text(firstFavorite.facility)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("즐겨찾기 없음")
                        .font(.headline)

                    Text("공연을 추가해보세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Image(systemName: "heart.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                Text("\(data.statistics.favoriteCount)")
                    .font(.caption)
                    .bold()
            }
        }
        .widgetLabel {
            Text("CurtainCall")
        }
    }
}

// MARK: - Inline Widget (인라인)
struct InlineWidgetView: View {
    let data: WidgetData

    var body: some View {
        if let firstFavorite = data.favoritePerformances.first {
            Text("\(firstFavorite.title) · \(data.statistics.favoriteCount)개")
        } else {
            Text("즐겨찾기 \(data.statistics.favoriteCount)개 · 관람 기록 \(data.statistics.recordCount)개")
        }
    }
}

// MARK: - Lock Screen Widget Configuration
@available(iOS 16.0, *)
struct CurtainCallLockScreenWidget: Widget {
    let kind: String = "CurtainCallLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            // iOS 버전에 따라 다른 뷰 사용
            if #available(iOS 17.0, *) {
                LockScreenWidgetContainerView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LockScreenWidgetContainerView(entry: entry)
            }
        }
        .configurationDisplayName("CurtainCall 잠금 화면")
        .description("즐겨찾기를 잠금 화면에서 확인하세요")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Container View
@available(iOS 16.0, *)
struct LockScreenWidgetContainerView: View {
    let entry: CurtainCallWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                CircularWidgetView(data: entry.widgetData)

            case .accessoryRectangular:
                RectangularWidgetView(data: entry.widgetData)

            case .accessoryInline:
                InlineWidgetView(data: entry.widgetData)

            default:
                CircularWidgetView(data: entry.widgetData)
            }
        }
        // 잠금 화면 위젯 전체를 탭하면 즐겨찾기 화면으로 이동
        .widgetURL(WidgetDeepLink.favorites.url)
    }
}

// MARK: - Preview
@available(iOS 16.0, *)
#Preview("Circular", as: .accessoryCircular) {
    CurtainCallLockScreenWidget()
} timeline: {
    CurtainCallWidgetEntry(
        date: .now,
        widgetData: WidgetData(
            favoritePerformances: [],
            statistics: WidgetStatistics(
                favoriteCount: 5,
                recordCount: 12,
                mostViewedGenre: "뮤지컬",
                thisYearCount: 8
            ),
            lastUpdated: .now
        )
    )
}

@available(iOS 16.0, *)
#Preview("Rectangular", as: .accessoryRectangular) {
    CurtainCallLockScreenWidget()
} timeline: {
    CurtainCallWidgetEntry(
        date: .now,
        widgetData: WidgetData(
            favoritePerformances: [
                WidgetPerformance(
                    id: "1",
                    title: "레미제라블",
                    facility: "블루스퀘어",
                    poster: nil,
                    startDate: "2024.01.01",
                    endDate: "2024.12.31",
                    genre: "뮤지컬"
                )
            ],
            statistics: WidgetStatistics(
                favoriteCount: 5,
                recordCount: 12,
                mostViewedGenre: "뮤지컬",
                thisYearCount: 8
            ),
            lastUpdated: .now
        )
    )
}

@available(iOS 16.0, *)
#Preview("Inline", as: .accessoryInline) {
    CurtainCallLockScreenWidget()
} timeline: {
    CurtainCallWidgetEntry(
        date: .now,
        widgetData: WidgetData(
            favoritePerformances: [
                WidgetPerformance(
                    id: "1",
                    title: "레미제라블",
                    facility: "블루스퀘어",
                    poster: nil,
                    startDate: "2024.01.01",
                    endDate: "2024.12.31",
                    genre: "뮤지컬"
                )
            ],
            statistics: WidgetStatistics(
                favoriteCount: 5,
                recordCount: 12,
                mostViewedGenre: "뮤지컬",
                thisYearCount: 8
            ),
            lastUpdated: .now
        )
    )
}

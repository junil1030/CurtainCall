//
//  CurtainCallWidget.swift
//  CurtainCallWidget
//
//  Created by 서준일 on 12/8/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    typealias Entry = CurtainCallWidgetEntry

    func placeholder(in context: Context) -> CurtainCallWidgetEntry {
        CurtainCallWidgetEntry(
            date: Date(),
            widgetData: WidgetDataProvider.shared.emptyWidgetData()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CurtainCallWidgetEntry) -> Void) {
        let widgetData = WidgetDataProvider.shared.getCachedWidgetData()
        let entry = CurtainCallWidgetEntry(date: Date(), widgetData: widgetData)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CurtainCallWidgetEntry>) -> Void) {
        // 캐시된 데이터 가져오기
        let widgetData = WidgetDataProvider.shared.getCachedWidgetData()
        let currentDate = Date()

        // 현재 시간의 엔트리 생성
        let entry = CurtainCallWidgetEntry(date: currentDate, widgetData: widgetData)

        // 1시간 후에 다시 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}

struct CurtainCallWidgetEntry: TimelineEntry {
    let date: Date
    let widgetData: WidgetData
}

struct CurtainCallWidgetEntryView: View {
    var entry: CurtainCallWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(data: entry.widgetData)
        case .systemMedium:
            MediumWidgetView(data: entry.widgetData)
        case .systemLarge:
            LargeWidgetView(data: entry.widgetData)
        default:
            SmallWidgetView(data: entry.widgetData)
        }
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    let data: WidgetData

    var body: some View {
        Link(destination: WidgetDeepLink.favorites.url!) {
            VStack(alignment: .leading, spacing: 8) {
                Text("CurtainCall")
                    .font(.headline)
                    .bold()

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(data.statistics.favoriteCount)개")
                            .font(.subheadline)
                    }

                    HStack {
                        Image(systemName: "theatermasks.fill")
                            .foregroundColor(.blue)
                        Text("\(data.statistics.recordCount)개")
                            .font(.subheadline)
                    }

                    if let genre = data.statistics.mostViewedGenre {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(genre)
                                .font(.subheadline)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let data: WidgetData

    var body: some View {
        HStack(spacing: 12) {
            // 왼쪽: 통계 (관람 기록으로 링크)
            Link(destination: WidgetDeepLink.records.url!) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CurtainCall")
                        .font(.headline)
                        .bold()

                    Divider()

                    VStack(alignment: .leading, spacing: 6) {
                        StatRow(icon: "heart.fill", color: .red, label: "즐겨찾기", value: "\(data.statistics.favoriteCount)개")
                        StatRow(icon: "theatermasks.fill", color: .blue, label: "관람 기록", value: "\(data.statistics.recordCount)개")
                        if let genre = data.statistics.mostViewedGenre {
                            StatRow(icon: "star.fill", color: .yellow, label: "선호 장르", value: genre)
                        }
                        StatRow(icon: "calendar", color: .green, label: "올해", value: "\(data.statistics.thisYearCount)개")
                    }

                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 오른쪽: 최근 즐겨찾기 (공연 상세로 링크)
            if let firstFavorite = data.favoritePerformances.first {
                Link(destination: WidgetDeepLink.performanceDetail(id: firstFavorite.id).url!) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("최근 즐겨찾기")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(firstFavorite.title)
                            .font(.subheadline)
                            .bold()
                            .lineLimit(2)

                        Text(firstFavorite.facility)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)

                        Spacer()

                        Text("\(firstFavorite.startDate) ~ \(firstFavorite.endDate)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Large Widget
struct LargeWidgetView: View {
    let data: WidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack {
                Text("CurtainCall")
                    .font(.title2)
                    .bold()
                Spacer()
                Text("즐겨찾기 \(data.statistics.favoriteCount)개")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // 통계
            HStack(spacing: 16) {
                StatCard(icon: "heart.fill", color: .red, label: "즐겨찾기", value: "\(data.statistics.favoriteCount)")
                StatCard(icon: "theatermasks.fill", color: .blue, label: "관람 기록", value: "\(data.statistics.recordCount)")
                if let genre = data.statistics.mostViewedGenre {
                    StatCard(icon: "star.fill", color: .yellow, label: "선호 장르", value: genre)
                }
            }

            // 최근 즐겨찾기 목록
            if !data.favoritePerformances.isEmpty {
                Text("최근 즐겨찾기")
                    .font(.headline)
                    .padding(.top, 4)

                ForEach(data.favoritePerformances.prefix(2)) { performance in
                    PerformanceRow(performance: performance)
                }
            } else {
                Spacer()
                Text("즐겨찾기한 공연이 없습니다")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }

            Spacer()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Helper Views
struct StatRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .bold()
        }
    }
}

struct StatCard: View {
    let icon: String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(value)
                .font(.headline)
                .bold()
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PerformanceRow: View {
    let performance: WidgetPerformance

    var body: some View {
        Link(destination: WidgetDeepLink.performanceDetail(id: performance.id).url!) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(performance.title)
                        .font(.subheadline)
                        .bold()
                        .lineLimit(1)

                    Text(performance.facility)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Text("\(performance.startDate) ~ \(performance.endDate)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Widget Definition
struct CurtainCallWidget: Widget {
    let kind: String = "CurtainCallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CurtainCallWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("CurtainCall")
        .description("즐겨찾기와 관람 기록을 한눈에 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    CurtainCallWidget()
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

#Preview(as: .systemMedium) {
    CurtainCallWidget()
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

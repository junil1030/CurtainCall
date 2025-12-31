//
//  PerformanceLiveActivity.swift
//  CurtainCallWidget
//
//  Created by 서준일 on 12/9/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Widget
@available(iOS 16.2, *)
struct PerformanceLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PerformanceActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            PerformanceLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Region (꾹 눌렀을 때)
                DynamicIslandExpandedRegion(.leading) {
                    // 왼쪽: 공연 정보
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.title)
                            .font(.headline)
                            .lineLimit(1)
                        Text(context.attributes.facility)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    // 오른쪽: D-Day
                    VStack(spacing: 2) {
                        if context.state.isStarted {
                            Text("진행중")
                                .font(.caption2)
                                .foregroundColor(.green)
                            Text("D+\(abs(context.state.dDay))")
                                .font(.title2)
                                .bold()
                        } else if context.state.dDay == 0 {
                            Text("오늘 시작!")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            Text("D-Day")
                                .font(.title2)
                                .bold()
                        } else {
                            Text("시작까지")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("D-\(context.state.dDay)")
                                .font(.title2)
                                .bold()
                        }
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    // 하단: 공연 기간
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(context.attributes.startDate) ~ \(context.attributes.endDate)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        if context.state.favoriteCount > 1 {
                            Text("즐겨찾기 \(context.state.favoriteCount)개 중")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)
                }
            } compactLeading: {
                // Compact Leading (왼쪽 아이콘)
                Image(systemName: "theatermasks.fill")
                    .foregroundColor(.blue)
            } compactTrailing: {
                // Compact Trailing (오른쪽 텍스트)
                if context.state.isStarted {
                    Text("D+\(abs(context.state.dDay))")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.green)
                } else if context.state.dDay == 0 {
                    Text("D-Day")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.orange)
                } else {
                    Text("D-\(context.state.dDay)")
                        .font(.caption2)
                        .bold()
                }
            } minimal: {
                // Minimal (최소 크기 - 가장 작을 때)
                Image(systemName: "theatermasks.fill")
                    .foregroundColor(.blue)
            }
            .widgetURL(WidgetDeepLink.favorites.url)
            .keylineTint(.blue)
        }
    }
}

// MARK: - Lock Screen View
@available(iOS 16.2, *)
struct PerformanceLiveActivityView: View {
    let context: ActivityViewContext<PerformanceActivityAttributes>

    var body: some View {
        VStack(spacing: 12) {
            // 헤더
            HStack {
                Image(systemName: "theatermasks.fill")
                    .foregroundColor(.blue)
                Text("CurtainCall")
                    .font(.caption)
                    .bold()
                Spacer()
                if context.state.favoriteCount > 1 {
                    Text("\(context.state.favoriteCount)개 중 가장 임박")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // 공연 정보
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.title)
                        .font(.headline)
                        .bold()
                        .lineLimit(2)

                    Text(context.attributes.facility)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Text("\(context.attributes.startDate) ~ \(context.attributes.endDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // D-Day 표시
                VStack(spacing: 4) {
                    if context.state.isStarted {
                        Text("진행중")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("D+\(abs(context.state.dDay))")
                            .font(.title)
                            .bold()
                            .foregroundColor(.green)
                        Text("종료까지 \(context.state.remainingDays)일")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else if context.state.dDay == 0 {
                        Text("오늘 시작!")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("D-Day")
                            .font(.title)
                            .bold()
                            .foregroundColor(.orange)
                    } else {
                        Text("시작까지")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("D-\(context.state.dDay)")
                            .font(.title)
                            .bold()
                        Text("\(context.state.dDay)일 남음")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .activityBackgroundTint(Color.black.opacity(0.1))
        .activitySystemActionForegroundColor(.blue)
    }
}

// MARK: - Preview
@available(iOS 16.2, *)
#Preview("Live Activity", as: .content, using: PerformanceActivityAttributes(
    performanceId: "1",
    title: "레미제라블",
    facility: "블루스퀘어 신한카드홀",
    startDate: "2025.12.16",
    endDate: "2026.03.30",
    genre: "뮤지컬"
)) {
    PerformanceLiveActivity()
} contentStates: {
    // D-7 (시작 전)
    PerformanceActivityAttributes.ContentState(
        dDay: 7,
        remainingDays: 111,
        isStarted: false,
        favoriteCount: 3
    )

    // D-Day (오늘 시작)
    PerformanceActivityAttributes.ContentState(
        dDay: 0,
        remainingDays: 104,
        isStarted: false,
        favoriteCount: 3
    )

    // D+5 (진행중)
    PerformanceActivityAttributes.ContentState(
        dDay: -5,
        remainingDays: 99,
        isStarted: true,
        favoriteCount: 3
    )
}

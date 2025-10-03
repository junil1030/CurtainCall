//
//  TrendChartView.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import SwiftUI
import Charts

struct TrendChartView: View {
    
    let dataPoints: [TrendDataPoint]
    let period: StatsPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 차트
            chartContent
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var chartContent: some View {
        Chart {
            ForEach(dataPoints, id: \.index) { point in
                BarMark(
                    x: .value("기간", point.label),
                    y: .value("관람", point.count)
                )
                .foregroundStyle(gradientColor)
                .cornerRadius(4)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel()
                    .font(.system(size: 11))
                    .foregroundStyle(textSecondaryColor)
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(textPrimaryColor)
            }
        }
        .frame(height: 180)
    }
    
    private var textSecondaryColor: Color {
        Color(uiColor: .ccSecondaryText)
    }
    
    private var textPrimaryColor: Color {
        Color(uiColor: .ccPrimaryText)
    }
    
    // 기간별 그라데이션 색상
    private var gradientColor: LinearGradient {
        switch period {
        case .weekly:
            return weeklyGradient
        case .monthly:
            return monthlyGradient
        case .yearly:
            return yearlyGradient
        }
    }
    
    private var weeklyGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 255/255, green: 179/255, blue: 128/255),
                Color(red: 255/255, green: 217/255, blue: 191/255)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    private var monthlyGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 92/255, green: 138/255, blue: 138/255),
                Color(red: 139/255, green: 181/255, blue: 181/255)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    private var yearlyGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 255/255, green: 153/255, blue: 102/255),
                Color(red: 255/255, green: 179/255, blue: 128/255)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

// MARK: - Preview
#Preview {
    let sampleData: [TrendDataPoint] = [
        TrendDataPoint(label: "월", count: 3, index: 1),
        TrendDataPoint(label: "화", count: 7, index: 2),
        TrendDataPoint(label: "수", count: 1, index: 3),
        TrendDataPoint(label: "목", count: 6, index: 4),
        TrendDataPoint(label: "금", count: 2, index: 5),
        TrendDataPoint(label: "토", count: 1, index: 6),
        TrendDataPoint(label: "일", count: 10, index: 7)
    ]
    
    return TrendChartView(dataPoints: sampleData, period: .weekly)
        .padding()
}

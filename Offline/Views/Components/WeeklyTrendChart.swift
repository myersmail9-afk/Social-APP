import SwiftUI
import Charts

/// A bar chart of daily total screen time over the week, with the goal drawn
/// as a dashed rule. Bars under goal are green; over-goal bars are red.
struct WeeklyTrendChart: View {
    let usage: [DailyUsage]
    let goalMinutes: Int

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEEE" // single-letter weekday
        return f
    }()

    var body: some View {
        Chart {
            ForEach(usage) { day in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Minutes", day.totalMinutes)
                )
                .foregroundStyle(day.totalMinutes <= goalMinutes ? Theme.good : Theme.over)
                .cornerRadius(6)
            }
            RuleMark(y: .value("Goal", goalMinutes))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 4]))
                .foregroundStyle(.secondary)
                .annotation(position: .top, alignment: .trailing) {
                    Text("Goal \(goalMinutes.asDuration)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(dayFormatter.string(from: date))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let minutes = value.as(Int.self) {
                        Text(minutes.asDuration)
                    }
                }
            }
        }
        .frame(height: 180)
    }
}

#Preview {
    WeeklyTrendChart(usage: SampleData.me.weeklyUsage, goalMinutes: 180)
        .padding()
}

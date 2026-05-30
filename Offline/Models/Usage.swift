import Foundation

/// Minutes of usage within a single category on a single day.
struct CategoryUsage: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var category: UsageCategory
    var minutes: Int
}

/// A full day of usage, broken down by category.
struct DailyUsage: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var date: Date
    var breakdown: [CategoryUsage]

    var totalMinutes: Int {
        breakdown.reduce(0) { $0 + $1.minutes }
    }

    func minutes(for category: UsageCategory) -> Int {
        breakdown.first(where: { $0.category == category })?.minutes ?? 0
    }

    /// Minutes spent in categories considered "well spent."
    var productiveMinutes: Int {
        breakdown.filter { $0.category.isProductive }.reduce(0) { $0 + $1.minutes }
    }
}

extension Array where Element == DailyUsage {
    /// Total screen time across all days in the collection.
    var totalMinutes: Int { reduce(0) { $0 + $1.totalMinutes } }

    /// Average daily screen time, rounded to the nearest minute.
    var averageDailyMinutes: Int {
        guard !isEmpty else { return 0 }
        return Int((Double(totalMinutes) / Double(count)).rounded())
    }

    /// Aggregated minutes per category across the whole collection.
    var aggregatedBreakdown: [CategoryUsage] {
        var totals: [UsageCategory: Int] = [:]
        for day in self {
            for item in day.breakdown {
                totals[item.category, default: 0] += item.minutes
            }
        }
        return UsageCategory.allCases.compactMap { category in
            guard let minutes = totals[category], minutes > 0 else { return nil }
            return CategoryUsage(category: category, minutes: minutes)
        }
        .sorted { $0.minutes > $1.minutes }
    }
}

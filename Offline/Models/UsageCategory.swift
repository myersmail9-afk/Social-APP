import SwiftUI

/// A generic, human-friendly grouping of app usage.
/// Mirrors the kinds of categories Apple's Screen Time exposes, but kept
/// deliberately small and opinionated so the experience stays clean.
enum UsageCategory: String, CaseIterable, Identifiable, Codable {
    case social
    case entertainment
    case productivity
    case music
    case games
    case health
    case education
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .social: return "Social"
        case .entertainment: return "Entertainment"
        case .productivity: return "Productivity"
        case .music: return "Music"
        case .games: return "Games"
        case .health: return "Health"
        case .education: return "Education"
        case .other: return "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .social: return "bubble.left.and.bubble.right.fill"
        case .entertainment: return "play.tv.fill"
        case .productivity: return "checkmark.seal.fill"
        case .music: return "music.note"
        case .games: return "gamecontroller.fill"
        case .health: return "heart.fill"
        case .education: return "books.vertical.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .social: return Color(hex: 0xFF5C8A)
        case .entertainment: return Color(hex: 0x8B5CF6)
        case .productivity: return Color(hex: 0x22C55E)
        case .music: return Color(hex: 0xF59E0B)
        case .games: return Color(hex: 0x3B82F6)
        case .health: return Color(hex: 0xEF4444)
        case .education: return Color(hex: 0x14B8A6)
        case .other: return Color(hex: 0x94A3B8)
        }
    }

    /// Whether time in this category generally counts as "well spent."
    /// Used purely for gentle, motivational framing — never to shame.
    var isProductive: Bool {
        switch self {
        case .productivity, .health, .education: return true
        default: return false
        }
    }
}

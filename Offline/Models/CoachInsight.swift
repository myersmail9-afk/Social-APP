import SwiftUI

/// A single piece of guidance from the (AI) coach. Always supportive — it
/// highlights wins, spots patterns, and suggests one small next step. Never
/// shames. Today these come from `MockCoachService`; later from the Claude API.
struct CoachInsight: Identifiable, Hashable {
    enum Tone: String {
        case win        // celebrate an improvement
        case tip        // a gentle, actionable suggestion
        case nudge      // a heads-up about a rising pattern
        case rivalry    // duel-related encouragement

        var systemImage: String {
            switch self {
            case .win: return "checkmark.seal.fill"
            case .tip: return "lightbulb.fill"
            case .nudge: return "exclamationmark.bubble.fill"
            case .rivalry: return "bolt.heart.fill"
            }
        }

        var color: Color {
            switch self {
            case .win: return Theme.good
            case .tip: return Theme.accent
            case .nudge: return Theme.warn
            case .rivalry: return Color(hex: 0xFF5C8A)
            }
        }
    }

    var id: UUID = UUID()
    var tone: Tone
    var title: String
    var message: String
}

/// A practical, bite-sized tactic for using your phone less. Powers the
/// "Toolkit" — the supportive counterweight to the competitive duels.
struct ToolkitTip: Identifiable, Hashable {
    enum Difficulty: String, CaseIterable {
        case easy, medium, bold

        var title: String {
            switch self {
            case .easy: return "Easy win"
            case .medium: return "Worth a try"
            case .bold: return "Bold move"
            }
        }

        var color: Color {
            switch self {
            case .easy: return Theme.good
            case .medium: return Theme.warn
            case .bold: return Theme.over
            }
        }
    }

    var id: UUID = UUID()
    var icon: String
    var title: String
    var detail: String
    var difficulty: Difficulty
}

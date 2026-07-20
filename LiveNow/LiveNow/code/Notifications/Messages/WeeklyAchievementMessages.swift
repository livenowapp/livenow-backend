//
//  WeeklyAchievementMessages.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 19. 7. 2026.
//

import Foundation

enum WeeklyAchievementMessages {

    // MARK: - RESET LEVEL

    private enum ResetLevel {
        case one
        case building
        case consistent
        case committed
    }

    // MARK: - WEEKLY RESULT

    private enum WeeklyResult {
        case unrated
        case mostlyNotWorthIt
        case mostlyWorthIt
        case mostlyMaybe
        case balanced
    }

    // MARK: - MAIN MESSAGE

    static func message(
        stats: WeeklyNotificationStats,
        seed: Int
    ) -> NotificationMessage {

        let level = resetLevel(
            resetCount: stats.resetCount
        )

        let result = weeklyResult(
            stats: stats
        )

        let messages = messages(
            level: level,
            result: result,
            stats: stats
        )

        return NotificationMessageSelector.select(
            from: messages,
            seed: seed
        )
    }

    // MARK: - RESET LEVEL

    private static func resetLevel(
        resetCount: Int
    ) -> ResetLevel {
        switch resetCount {
        case 1:
            return .one

        case 2...4:
            return .building

        case 5...9:
            return .consistent

        default:
            return .committed
        }
    }

    // MARK: - WEEKLY RESULT

    private static func weeklyResult(
        stats: WeeklyNotificationStats
    ) -> WeeklyResult {

        guard stats.resolvedCount > 0 else {
            return .unrated
        }

        if stats.notWorthItPercentage >= 70 {
            return .mostlyNotWorthIt
        }

        if stats.worthItPercentage >= 70 {
            return .mostlyWorthIt
        }

        if stats.maybePercentage >= 70 {
            return .mostlyMaybe
        }

        return .balanced
    }

    // MARK: - MESSAGE SELECTION

    private static func messages(
        level: ResetLevel,
        result: WeeklyResult,
        stats: WeeklyNotificationStats
    ) -> [NotificationMessage] {

        switch (level, result) {

        // MARK: One reset — unrated

        case (.one, .unrated):
            return [
                NotificationMessage(
                    id: "weekly-one-unrated-1-\(stats.resetCount)",
                    title: "One pause made a difference",
                    body:
                        "You completed one reset this week and gave your mind space to slow down."
                ),

                NotificationMessage(
                    id: "weekly-one-unrated-2-\(stats.resetCount)",
                    title: "You made space for yourself",
                    body:
                        "One reset can be enough to see a thought from a clearer perspective."
                ),
                
                NotificationMessage(
                    id: "weekly-one-unrated-3-\(stats.resetCount)",
                    title: "Every reset matters",
                    body:
                        "You took one moment this week to check in with yourself. That's always a step toward greater clarity."
                )
            ]

        // MARK: One reset — mostly not worth it

        case (.one, .mostlyNotWorthIt):
            return [
                NotificationMessage(
                    id: "weekly-one-not-worth-1-\(stats.resetCount)",
                    title: "That thought felt lighter",
                    body:
                        "Your reset helped you recognize that this worry was not worth carrying."
                ),

                NotificationMessage(
                    id: "weekly-one-not-worth-2-\(stats.resetCount)",
                    title: "One reset, clearer perspective",
                    body:
                        "You paused once this week and saw that the worry did not deserve so much of your energy."
                ),
                
                NotificationMessage(
                    id: "weekly-one-not-worth-3-\(stats.resetCount)",
                    title: "You saw it differently",
                    body:
                        "One reset helped you realize this thought didn't deserve as much of your energy."
                )
            ]

        // MARK: One reset — mostly worth it

        case (.one, .mostlyWorthIt):
            return [
                NotificationMessage(
                    id: "weekly-one-worth-1-\(stats.resetCount)",
                    title: "You faced what mattered",
                    body:
                        "Your reset helped you give an important thought the attention it needed."
                ),

                NotificationMessage(
                    id: "weekly-one-worth-2-\(stats.resetCount)",
                    title: "A meaningful pause",
                    body:
                        "You slowed down and recognized a concern that was worth taking seriously."
                ),
                
                NotificationMessage(
                    id: "weekly-one-worth-3-\(stats.resetCount)",
                    title: "You trusted yourself",
                    body:
                        "You paused long enough to recognize a concern that truly mattered."
                )
            ]

        // MARK: One reset — mostly maybe

        case (.one, .mostlyMaybe):
            return [
                NotificationMessage(
                    id: "weekly-one-maybe-1-\(stats.resetCount)",
                    title: "You allowed uncertainty",
                    body:
                        "Your reset helped you see that not every thought needs an immediate answer."
                ),

                NotificationMessage(
                    id: "weekly-one-maybe-2-\(stats.resetCount)",
                    title: "Not everything is certain yet",
                    body:
                        "You made space for a thought without forcing yourself to decide what it meant."
                ),
                
                NotificationMessage(
                    id: "weekly-one-maybe-3-\(stats.resetCount)",
                    title: "It's okay not to know yet",
                    body:
                        "Some thoughts become clearer with time. Your reset gave that process room to happen."
                )
            ]

        // MARK: One reset — balanced

        case (.one, .balanced):
            return [
                NotificationMessage(
                    id: "weekly-one-balanced-1-\(stats.resetCount)",
                    title: "One thoughtful moment",
                    body:
                        "You paused, reflected, and gave yourself a clearer view of what was happening."
                ),

                NotificationMessage(
                    id: "weekly-one-balanced-2-\(stats.resetCount)",
                    title: "A small step toward clarity",
                    body:
                        "One reset helped you separate the thought from the emotion around it."
                ),
                
                NotificationMessage(
                    id: "weekly-one-balanced-3-\(stats.resetCount)",
                    title: "A thoughtful pause",
                    body:
                        "One reset was enough to look at your thoughts with a little more perspective."
                )
            ]

        // MARK: Building — unrated

        case (.building, .unrated):
            return [
                NotificationMessage(
                    id: "weekly-building-unrated-1-\(stats.resetCount)",
                    title: "You are building the habit",
                    body:
                        "You completed \(stats.resetCount) \(resetWord(stats.resetCount)) this week and made time for a clearer mind."
                ),

                NotificationMessage(
                    id: "weekly-building-unrated-2-\(stats.resetCount)",
                    title: "Small pauses add up",
                    body:
                        "You made space for yourself \(stats.resetCount) \(timeWord(stats.resetCount)) this week."
                ),
                
                NotificationMessage(
                    id: "weekly-building-unrated-3-\(stats.resetCount)",
                    title: "A habit is beginning",
                    body:
                        "Every reset was another step toward a calmer mind."
                )
            ]

        // MARK: Building — mostly not worth it

        case (.building, .mostlyNotWorthIt):
            return [
                NotificationMessage(
                    id: "weekly-building-not-worth-1-\(stats.resetCount)",
                    title: "You caught the overthinking",
                    body:
                        "You completed \(stats.resetCount) \(resetWord(stats.resetCount)). " +
                        "\(stats.notWorthItPercentage)% of your rated worries were not worth overthinking."
                ),

                NotificationMessage(
                    id: "weekly-building-not-worth-2-\(stats.resetCount)",
                    title: "Your worries lost some power",
                    body:
                        "Most of the thoughts you examined this week did not deserve as much energy as they received."
                ),
                
                NotificationMessage(
                    id: "weekly-building-not-worth-3-\(stats.resetCount)",
                    title: "You noticed what was only noise",
                    body:
                        "Your resets helped you recognize that many worries did not deserve so much attention."
                )
            ]

        // MARK: Building — mostly worth it

        case (.building, .mostlyWorthIt):
            return [
                NotificationMessage(
                    id: "weekly-building-worth-1-\(stats.resetCount)",
                    title: "You gave attention to what mattered",
                    body:
                        "You completed \(stats.resetCount) \(resetWord(stats.resetCount)) and recognized which thoughts needed real attention."
                ),

                NotificationMessage(
                    id: "weekly-building-worth-2-\(stats.resetCount)",
                    title: "You faced important thoughts",
                    body:
                        "This week, your resets helped you respond thoughtfully instead of avoiding what mattered."
                ),
                
                NotificationMessage(
                    id: "weekly-building-worth-3-\(stats.resetCount)",
                    title: "You paid attention with purpose",
                    body:
                        "This week, you used your resets to recognize concerns that were worth responding to."
                )
            ]

        // MARK: Building — mostly maybe

        case (.building, .mostlyMaybe):
            return [
                NotificationMessage(
                    id: "weekly-building-maybe-1-\(stats.resetCount)",
                    title: "You made room for uncertainty",
                    body:
                        "You completed \(stats.resetCount) \(resetWord(stats.resetCount)) without forcing every thought into a final answer."
                ),

                NotificationMessage(
                    id: "weekly-building-maybe-2-\(stats.resetCount)",
                    title: "Some thoughts need more time",
                    body:
                        "Your resets helped you pause before deciding whether a worry was real or only overthinking."
                ),
                
                NotificationMessage(
                    id: "weekly-building-maybe-3-\(stats.resetCount)",
                    title: "You gave yourself time",
                    body:
                        "Your resets created space for uncertainty without asking you to solve everything immediately."
                )
            ]

        // MARK: Building — balanced

        case (.building, .balanced):
            return [
                NotificationMessage(
                    id: "weekly-building-balanced-1-\(stats.resetCount)",
                    title: "You gave your thoughts perspective",
                    body:
                        "\(stats.resetCount) \(capitalizedResetWord(stats.resetCount)) helped you separate real concerns from overthinking."
                ),

                NotificationMessage(
                    id: "weekly-building-balanced-2-\(stats.resetCount)",
                    title: "A clearer week",
                    body:
                        "You paused and reflected \(stats.resetCount) \(timeWord(stats.resetCount)) this week."
                ),
                
                NotificationMessage(
                    id: "weekly-building-balanced-3-\(stats.resetCount)",
                    title: "You are learning what needs your energy",
                    body:
                        "This week's resets helped you see what deserved your attention."
                )
            ]

        // MARK: Consistent — unrated

        case (.consistent, .unrated):
            return [
                NotificationMessage(
                    id: "weekly-consistent-unrated-1-\(stats.resetCount)",
                    title: "You showed real consistency",
                    body:
                        "You completed \(stats.resetCount) \(resetWord(stats.resetCount)) this week and kept returning to a calmer perspective."
                ),

                NotificationMessage(
                    id: "weekly-consistent-unrated-2-\(stats.resetCount)",
                    title: "Clarity became a practice",
                    body:
                        "You paused \(stats.resetCount) \(timeWord(stats.resetCount)) instead of letting every thought take control."
                ),
                
                NotificationMessage(
                    id: "weekly-consistent-unrated-3-\(stats.resetCount)",
                    title: "You kept showing up for yourself",
                    body:
                        "You completed \(stats.resetCount) \(resetWord(stats.resetCount)) and made reflection part of your week."
                )
            ]

        // MARK: Consistent — mostly not worth it

        case (.consistent, .mostlyNotWorthIt):
            return [
                NotificationMessage(
                    id: "weekly-consistent-not-worth-1-\(stats.resetCount)",
                    title: "You are spotting overthinking sooner",
                    body:
                        "You completed \(stats.resetCount) \(resetWord(stats.resetCount)). " +
                        "\(stats.notWorthItPercentage)% of your rated worries were not worth carrying."
                ),

                NotificationMessage(
                    id: "weekly-consistent-not-worth-2-\(stats.resetCount)",
                    title: "Your perspective is getting stronger",
                    body:
                        "Most of the worries you examined this week became lighter once you looked at them clearly."
                ),
                
                NotificationMessage(
                    id: "weekly-consistent-not-worth-3-\(stats.resetCount)",
                    title: "You interrupted the overthinking",
                    body:
                        "Again and again, you paused long enough to see that many worries were heavier than they needed to be."
                )
            ]

        // MARK: Consistent — mostly worth it

        case (.consistent, .mostlyWorthIt):
            return [
                NotificationMessage(
                    id: "weekly-consistent-worth-1-\(stats.resetCount)",
                    title: "You stayed present for what mattered",
                    body:
                        "Your \(stats.resetCount) \(resetWord(stats.resetCount)) helped you give important concerns thoughtful attention."
                ),

                NotificationMessage(
                    id: "weekly-consistent-worth-2-\(stats.resetCount)",
                    title: "You responded instead of avoiding",
                    body:
                        "This week, you consistently faced thoughts that deserved your attention."
                ),
                
                NotificationMessage(
                    id: "weekly-consistent-worth-3-\(stats.resetCount)",
                    title: "You stayed connected to what mattered",
                    body:
                        "Your resets helped you consistently recognize concerns that deserved thoughtful attention."
                )
            ]

        // MARK: Consistent — mostly maybe

        case (.consistent, .mostlyMaybe):
            return [
                NotificationMessage(
                    id: "weekly-consistent-maybe-1-\(stats.resetCount)",
                    title: "You became more comfortable with uncertainty",
                    body:
                        "Your \(stats.resetCount) \(resetWord(stats.resetCount)) helped you pause without demanding immediate certainty."
                ),

                NotificationMessage(
                    id: "weekly-consistent-maybe-2-\(stats.resetCount)",
                    title: "You did not rush the answer",
                    body:
                        "Many of this week's thoughts needed time, and you allowed yourself not to know yet."
                ),
                
                NotificationMessage(
                    id: "weekly-consistent-maybe-3-\(stats.resetCount)",
                    title: "You let clarity arrive naturally",
                    body:
                        "Instead of rushing uncertain thoughts, you repeatedly gave them time to become clearer."
                )
            ]

        // MARK: Consistent — balanced

        case (.consistent, .balanced):
            return [
                NotificationMessage(
                    id: "weekly-consistent-balanced-1-\(stats.resetCount)",
                    title: "You created a clearer week",
                    body:
                        "\(stats.resetCount) \(capitalizedResetWord(stats.resetCount)) helped you respond to different thoughts with more perspective."
                ),

                NotificationMessage(
                    id: "weekly-consistent-balanced-2-\(stats.resetCount)",
                    title: "You listened without getting lost",
                    body:
                        "You consistently made room for your thoughts without letting them control the whole week."
                ),
                
                NotificationMessage(
                    id: "weekly-consistent-balanced-3-\(stats.resetCount)",
                    title: "You responded with more perspective",
                    body:
                        "Throughout the week, you made space for different thoughts without treating them all the same."
                )
            ]

        // MARK: Committed — unrated

        case (.committed, .unrated):
            return [
                NotificationMessage(
                    id: "weekly-committed-unrated-1-\(stats.resetCount)",
                    title: "You made clarity a priority",
                    body:
                        "You completed \(stats.resetCount) \(resetWord(stats.resetCount)) this week. That is real commitment to your peace of mind."
                ),

                NotificationMessage(
                    id: "weekly-committed-unrated-2-\(stats.resetCount)",
                    title: "A week of intentional pauses",
                    body:
                        "You chose to reset \(stats.resetCount) \(timeWord(stats.resetCount)) instead of staying trapped in your thoughts."
                ),
                
                NotificationMessage(
                    id: "weekly-committed-unrated-3-\(stats.resetCount)",
                    title: "You made your mind a priority",
                    body:
                        "With \(stats.resetCount) \(resetWord(stats.resetCount)), you chose clarity over staying stuck."
                )
            ]

        // MARK: Committed — mostly not worth it

        case (.committed, .mostlyNotWorthIt):
            return [
                NotificationMessage(
                    id: "weekly-committed-not-worth-1-\(stats.resetCount)",
                    title: "You took power away from overthinking",
                    body:
                        "You completed \(stats.resetCount) \(resetWord(stats.resetCount)), and \(stats.notWorthItPercentage)% of your rated worries were not worth carrying."
                ),

                NotificationMessage(
                    id: "weekly-committed-not-worth-2-\(stats.resetCount)",
                    title: "You saw through the noise",
                    body:
                        "Most of the worries you examined this week lost their weight once you gave them perspective."
                ),
                
                NotificationMessage(
                    id: "weekly-committed-not-worth-3-\(stats.resetCount)",
                    title: "You released what did not deserve you",
                    body:
                        "Your consistent resets helped you see how often overthinking was asking for more energy than it deserved."
                )
            ]

        // MARK: Committed — mostly worth it

        case (.committed, .mostlyWorthIt):
            return [
                NotificationMessage(
                    id: "weekly-committed-worth-1-\(stats.resetCount)",
                    title: "You consistently faced what mattered",
                    body:
                        "Your \(stats.resetCount) \(resetWord(stats.resetCount)) helped you stay present for concerns that deserved real attention."
                ),

                NotificationMessage(
                    id: "weekly-committed-worth-2-\(stats.resetCount)",
                    title: "You showed up for important thoughts",
                    body:
                        "This week, you repeatedly chose thoughtful action over avoidance."
                ),
                
                NotificationMessage(
                    id: "weekly-committed-worth-3-\(stats.resetCount)",
                    title: "You acted with awareness",
                    body:
                        "This week, you repeatedly recognized important concerns and gave them the attention they needed."
                )
            ]

        // MARK: Committed — mostly maybe

        case (.committed, .mostlyMaybe):
            return [
                NotificationMessage(
                    id: "weekly-committed-maybe-1-\(stats.resetCount)",
                    title: "You practiced patience with uncertainty",
                    body:
                        "You completed \(stats.resetCount) \(resetWord(stats.resetCount)) without forcing every uncertain thought into an answer."
                ),

                NotificationMessage(
                    id: "weekly-committed-maybe-2-\(stats.resetCount)",
                    title: "You gave uncertainty some space",
                    body:
                        "This week, you repeatedly paused before deciding what your thoughts really meant."
                ),
                
                NotificationMessage(
                    id: "weekly-committed-maybe-3-\(stats.resetCount)",
                    title: "You stayed patient with the unknown",
                    body:
                        "Over \(stats.resetCount) \(resetWord(stats.resetCount)), you allowed uncertainty without letting it control you."
                )
            ]

        // MARK: Committed — balanced

        case (.committed, .balanced):
            return [
                NotificationMessage(
                    id: "weekly-committed-balanced-1-\(stats.resetCount)",
                    title: "You built a week of perspective",
                    body:
                        "\(stats.resetCount) \(capitalizedResetWord(stats.resetCount)) helped you tell the difference between overthinking, uncertainty, and real concern."
                ),

                NotificationMessage(
                    id: "weekly-committed-balanced-2-\(stats.resetCount)",
                    title: "You kept returning to clarity",
                    body:
                        "You kept making space to understand your thoughts."
                ),
                
                NotificationMessage(
                    id: "weekly-committed-balanced-3-\(stats.resetCount)",
                    title: "You met each thought differently",
                    body:
                        "Your resets helped you respond to each thought with greater clarity."
                )
            ]
        }
    }

    // MARK: - WORDS

    private static func resetWord(
        _ count: Int
    ) -> String {
        count == 1 ? "reset" : "resets"
    }

    private static func capitalizedResetWord(
        _ count: Int
    ) -> String {
        count == 1 ? "Reset" : "Resets"
    }

    private static func timeWord(
        _ count: Int
    ) -> String {
        count == 1 ? "time" : "times"
    }
}

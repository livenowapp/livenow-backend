//
//  EveningNotification.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 18. 7. 2026.
//

import Foundation

enum EveningNotificationMessages {
    
    // MARK: - GENERAL
    
    static let general: [NotificationMessage] = [
        NotificationMessage(
            id: "evening-general-1",
            title: "You made it through today",
            body: "You do not need to carry every thought into tomorrow."
        ),
        
        NotificationMessage(
            id: "evening-general-2",
            title: "Let today be enough",
            body: "Give your mind permission to slow down for the evening."
        ),
        
        NotificationMessage(
            id: "evening-general-3",
            title: "Time to release the day",
            body: "Not every thought needs an answer before you rest."
        ),
        
        NotificationMessage(
            id: "evening-general-4",
            title: "Your mind can rest now",
            body: "You can return to unfinished thoughts another day."
        ),
        
        NotificationMessage(
            id: "evening-general-5",
            title: "Come back to the present",
            body: "Take one slow breath and let the day soften."
        ),
        
        NotificationMessage(
            id: "evening-general-6",
            title: "Leave some space for rest",
            body: "You have done enough thinking for one day."
        )
    ]
    
    // MARK: - NEED
    
    static func forNeed(
        _ need: String?
    ) -> [NotificationMessage] {
        
        switch OnboardingNeed(
            storedValue: need
        ) {
            
        case .calm:
            return [
                NotificationMessage(
                    id: "evening_need_calm_001",
                    title: "Peace doesn't require every answer",
                    body: "Let tonight be quieter than the thoughts you carried today."
                ),

                NotificationMessage(
                    id: "evening_need_calm_002",
                    title: "Choose calm tonight",
                    body: "You can pause the problem without solving it."
                ),

                NotificationMessage(
                    id: "evening_need_calm_003",
                    title: "Your mind deserves quiet",
                    body: "Set down what you can't control before you rest."
                )
            ]
            
        case .confidence:
            return [
                NotificationMessage(
                    id: "evening-need-confidence-1",
                    title: "You handled more than you noticed",
                    body: "Trust yourself a little more than your doubts tonight."
                ),
                
                NotificationMessage(
                    id: "evening-need-confidence-2",
                    title: "You do not need perfect certainty",
                    body: "You can trust the choices you made today."
                ),
                
                NotificationMessage(
                    id: "evening-need-confidence-3",
                    title: "Let self-doubt rest too",
                    body: "You are allowed to stop reviewing everything you did."
                )
            ]
            
        case .clarity:
            return [
                NotificationMessage(
                    id: "evening-need-clarity-1",
                    title: "Clarity can wait until morning",
                    body: "A rested mind often sees things more clearly."
                ),
                
                NotificationMessage(
                    id: "evening-need-clarity-2",
                    title: "You do not need to solve it tonight",
                    body: "Give the thought some distance and return to it later."
                ),
                
                NotificationMessage(
                    id: "evening-need-clarity-3",
                    title: "Space creates perspective",
                    body: "Step away from the thought and let your mind reset."
                )
            ]
            
        case .lessOverthinking:
            return [
                NotificationMessage(
                    id: "evening_need_less_overthinking_001",
                    title: "You don't have to carry today anymore",
                    body: "Let today's thoughts stay in today. Tomorrow is a new beginning."
                ),

                NotificationMessage(
                    id: "evening_need_less_overthinking_002",
                    title: "Your mind deserves some quiet",
                    body: "Not every question needs an answer before you fall asleep."
                ),

                NotificationMessage(
                    id: "evening_need_less_overthinking_003",
                    title: "It's okay to let go",
                    body: "You have done enough for today. Give your mind permission to rest."
                )
            ]
            
        case .betterHabits:
            return [
                NotificationMessage(
                    id: "evening-need-habits-1",
                    title: "End the day with one calm choice",
                    body: "A small pause tonight can become a stronger habit tomorrow."
                ),
                
                NotificationMessage(
                    id: "evening-need-habits-2",
                    title: "Consistency grows quietly",
                    body: "Every time you pause instead of spiral, the habit becomes stronger."
                ),
                
                NotificationMessage(
                    id: "evening-need-habits-3",
                    title: "One gentle habit before sleep",
                    body: "Notice the thought, release it, and return to the present."
                )
            ]
            
        case nil:
            return []
        }
    }
    
    // MARK: - THINKER TYPE
    
    static func forThinkerType(
        _ thinkerType: String?
    ) -> [NotificationMessage] {
        
        switch OnboardingThinkerType(
            storedValue: thinkerType
        ) {
            
        case .replayPastConversations:
            return [
                NotificationMessage(
                    id: "evening-thinker-past-1",
                    title: "The conversation is over",
                    body: "You do not need to keep rewriting it in your head."
                ),
                
                NotificationMessage(
                    id: "evening-thinker-past-2",
                    title: "Let the past stay finished",
                    body: "Replaying it will not give you a different ending tonight."
                ),
                
                NotificationMessage(
                    id: "evening-thinker-past-3",
                    title: "You can stop reviewing it",
                    body: "What was said does not need another mental replay."
                )
            ]
            
        case .worryAboutFuture:
            return [
                NotificationMessage(
                    id: "evening-thinker-future-1",
                    title: "Tomorrow is not here yet",
                    body: "You only need to be where you are tonight."
                ),
                
                NotificationMessage(
                    id: "evening-thinker-future-2",
                    title: "The future can wait",
                    body: "Rest before asking your mind to solve tomorrow."
                ),
                
                NotificationMessage(
                    id: "evening-thinker-future-3",
                    title: "Come back from tomorrow",
                    body: "Right now, you are safe in this moment."
                )
            ]
            
        case .overanalyzeDecisions:
            return [
                NotificationMessage(
                    id: "evening-thinker-decisions-1",
                    title: "The decision does not need another review",
                    body: "More thinking is not always more clarity."
                ),
                
                NotificationMessage(
                    id: "evening-thinker-decisions-2",
                    title: "Let your choice rest",
                    body: "You can stop comparing every possible outcome tonight."
                ),
                
                NotificationMessage(
                    id: "evening-thinker-decisions-3",
                    title: "Enough analysis for today",
                    body: "Trust that you can adjust later if you need to."
                )
            ]
            
        case .assumeWorst:
            return [
                NotificationMessage(
                    id: "evening-thinker-worst-1",
                    title: "A fear is not a prediction",
                    body: "The worst-case scenario is only one possibility."
                ),
                
                NotificationMessage(
                    id: "evening-thinker-worst-2",
                    title: "Your mind is trying to protect you",
                    body: "But you do not need to believe every warning it creates."
                ),
                
                NotificationMessage(
                    id: "evening-thinker-worst-3",
                    title: "Uncertainty does not mean danger",
                    body: "Let tonight remain open instead of assuming the worst."
                )
            ]
            
        case .mixed:
            return [
                NotificationMessage(
                    id: "evening-thinker-everything-1",
                    title: "You do not need to untangle everything",
                    body: "Choose one thought to release and let the rest wait."
                ),
                
                NotificationMessage(
                    id: "evening-thinker-everything-2",
                    title: "Your mind has done enough",
                    body: "Past, future, and decisions can all wait until tomorrow."
                ),
                
                NotificationMessage(
                    id: "evening-thinker-everything-3",
                    title: "Close the mental tabs",
                    body: "You can return to what matters with a rested mind."
                )
            ]
            
        case nil:
            return []
        }
    }
    
    // MARK: - REASON
    
    static func forReason(
        _ reason: String?
    ) -> [NotificationMessage] {
        switch OnboardingReason(
            storedValue: reason
        ) {
            
        case .overthinkOften:
            return [
                NotificationMessage(
                    id: "evening-reason-overthink-1",
                    title: "Not every thought needs more thought",
                    body: "Let one thing remain unresolved tonight."
                ),
                
                NotificationMessage(
                    id: "evening-reason-overthink-2",
                    title: "Your mind can stop searching",
                    body: "You do not need one more answer before resting."
                ),
                
                NotificationMessage(
                    id: "evening-reason-overthink-3",
                    title: "Thinking longer is not always thinking better",
                    body: "Give yourself permission to pause."
                )
            ]
            
        case .anxietyOften:
            return [
                NotificationMessage(
                    id: "evening-reason-anxiety-1",
                    title: "Slow the moment down",
                    body: "Take one gentle breath and notice that you are here."
                ),
                
                NotificationMessage(
                    id: "evening-reason-anxiety-2",
                    title: "You do not have to fight the feeling",
                    body: "Let it pass through without following every thought."
                ),
                
                NotificationMessage(
                    id: "evening-reason-anxiety-3",
                    title: "Return to what is real right now",
                    body: "Feel your breath, your body, and the space around you."
                )
            ]
            
        case .moreClarity:
            return [
                NotificationMessage(
                    id: "evening-reason-clarity-1",
                    title: "Distance can bring clarity",
                    body: "Step away from the thought and let your mind settle."
                ),
                
                NotificationMessage(
                    id: "evening-reason-clarity-2",
                    title: "You may see it differently tomorrow",
                    body: "Rest can reveal what overthinking hides."
                ),
                
                NotificationMessage(
                    id: "evening-reason-clarity-3",
                    title: "Clarity does not need force",
                    body: "Sometimes it arrives after you stop searching."
                )
            ]
            
        case .healthierHabits:
            return [
                NotificationMessage(
                    id: "evening-reason-habits-1",
                    title: "Practice ending the spiral",
                    body: "Notice the thought, name it, and choose not to follow it."
                ),
                
                NotificationMessage(
                    id: "evening-reason-habits-2",
                    title: "A healthier pattern starts small",
                    body: "One calm pause tonight is enough."
                ),
                
                NotificationMessage(
                    id: "evening-reason-habits-3",
                    title: "Repeat the pause, not the worry",
                    body: "Each time you return to the present, the habit becomes easier."
                )
            ]
            
        case .morePeaceOfMind:
            return [
                NotificationMessage(
                    id: "evening_reason_peace_001",
                    title: "Leave today behind",
                    body: "You don't have to carry today's thoughts into tomorrow."
                ),

                NotificationMessage(
                    id: "evening_reason_peace_002",
                    title: "Peace begins with letting go",
                    body: "Some thoughts become lighter when you stop holding onto them."
                ),

                NotificationMessage(
                    id: "evening_reason_peace_003",
                    title: "End the day with calm",
                    body: "You have done enough for today. Let your mind rest."
                )
            ]
            
        case nil:
            return []
        }
    }
}

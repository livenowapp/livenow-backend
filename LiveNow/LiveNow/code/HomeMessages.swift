//
//  HomeMessages.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 26. 7. 2026.
//

import Foundation

enum HomeMessages {

    static let all = [

        "you don’t need to figure\neverything out right now",

        "not every thought\ndeserves your attention",

        "let this moment\nbe enough",

        "one reset can change\nyour day",

        "let your mind\nrest for a moment",

        "you don't have to solve\ntomorrow today",

        "slow down.\nthis moment is enough",

        "peace begins\nwith one pause",

        "you can let this thought\npass without following it",

        "clarity doesn't come\nfrom overthinking",

        "not every question\nneeds an answer today",

        "some thoughts become quieter\nwhen you stop feeding them",

        "you don't have to prepare\nfor every possibility",

        "what if everything\nturns out okay?",

        "this moment deserves\nmore attention than your worries",

        "you are safe enough\nto slow down",

        "give your mind\npermission to breathe",

        "you don't have to carry\nevery thought",

        "there is nothing\nyou need to solve right now",

        "come back to\nwhat is real",

        "you are allowed\nto pause",

        "your next step\ndoesn't have to be perfect",

        "not knowing yet\nis completely okay",

        "one calm breath\nis a good place to start",

        "you don't have to\ncontrol every outcome",

        "today can be simpler\nthan your mind says",

        "rest your mind\nfor a little while",

        "your thoughts are not\nalways telling the truth",

        "you can stop searching\nfor certainty",

        "let go of\nwhat hasn't happened",

        "this thought can stay\nwithout leading you",

        "you don't have to\nbelieve every thought",

        "the present moment\nis waiting for you",

        "your peace matters\nmore than perfect answers",

        "give yourself\na quieter moment",

        "your mind deserves\nsome silence",

        "take one breath\nbefore the next thought",

        "life happens here.\nnot in your worries.",

        "your best decisions\ncome from a calmer mind",

        "every reset is\na fresh beginning"
    ]

    static func random() -> String {
        all.randomElement()
            ?? "you don’t need to figure\neverything out right now"
    }
}

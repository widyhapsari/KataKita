//
//  FeedbackType.swift
//  KataKita
//
//  Created by Keinan Wardhana on 18/06/25.
//

import Foundation

enum FeedbackType {
    case positive, negative
    
    var backgroundImage: String {
        switch self {
        case .positive: return "FeedbackFramePositive"
        case .negative: return "FeedbackFrameNegative"
        }
    }
    
    var mascotImage: String {
        switch self {
        case .positive: return "kero"
        case .negative: return "kerosad"
        }
    }
    
    var speechTop: String {
        switch self {
        case .positive: return "Sugoi Ne!"
        case .negative: return "Haa... motto tasukerareta noni."
        }
    }
    
    var speechMiddle: String {
        switch self {
        case .positive: return "すごいね！"
        case .negative: return "はぁ...もっと助けられたのに"
        }
    }
    
    var speechBottom: String {
        switch self {
        case .positive: return "You're amazing!"
        case .negative: return "I could’ve helped more."
        }
    }
    
    var feedbackTitle: String {
        switch self {
        case .positive: return "The restaurant staff totally got you!"
        case .negative: return "The restaurant staff looked a bit confused!"
        }
    }
    
    var feedbackSubtitle: String {
        switch self {
        case .positive: return "Your speaking’s hotter than the dish! Keep it up and master any food talk in Japan."
        case .negative: return "Let’s try serving that line again with extra flavor!"
        }
    }
}

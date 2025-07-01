//
//  PathItem.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct PathItem: Identifiable {
    let id = UUID()
    let title: String?
    let isLocked: Bool
}

let pathItems: [PathItem] = [
    PathItem(title: "Conversation 5", isLocked: true),
    PathItem(title: "Conversation 4", isLocked: true),
    PathItem(title: "Conversation 3", isLocked: true),
    PathItem(title: "Conversation 2", isLocked: true),
    PathItem(title: "Conversation 1", isLocked: false)
]

//
//  Vocab.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 17/06/25.
//

import SwiftUI

struct Vocab: Identifiable {
    let id: UUID = UUID()
    let name: String
    let image: String
    let nihongo: String
    let english: String
    let audio_name: String
}

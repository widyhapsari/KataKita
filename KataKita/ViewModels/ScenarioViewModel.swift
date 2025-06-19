//
//  ScenarioViewModel.swift
//  KataKita
//
//  Created by Rastya Widya Hapsari on 18/06/25.
//

import SwiftUI

enum ScenarioViewModelState {
    case loading
    case loaded
    case error(Error)
}

class ScenarioViewModel: ObservableObject {
    @Published private(set) var state: ScenarioViewModelState = .loading
}

extension ScenarioViewModel {
    func updateState(_ state: ScenarioViewModelState) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
}

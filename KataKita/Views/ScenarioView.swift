//
//  ScenarioView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct ScenarioView: View {
    var value: Double {
        return 3/3
    }
    
    var body: some View {
        VStack {
            ProgressView(value: value)
                .padding()
            
            Color.cyan
                .cornerRadius(12)
            
            Guide()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        ScenarioView()
    }
}

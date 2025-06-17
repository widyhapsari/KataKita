//
//  Welcome.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct Welcome: View {
    var body: some View {
        VStack {
            // Welcome Box
            VStack(spacing: 8) {
                Text("Welcome to KataKita")
                    .font(.title)
                    .bold()

                Text("いらっしゃいませ")
                    .multilineTextAlignment(.center)
                    .font(.headline)

                Text("Let’s practice real-life conversations!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

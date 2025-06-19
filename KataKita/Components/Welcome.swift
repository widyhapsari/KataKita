//
//  Welcome.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct Welcome: View {
    var body: some View {
        ZStack {
            Image("signSecondary")
                .resizable()
                .frame(width: 360, height: 180)
            
            VStack(spacing: 8) {
                Text("Welcome to KataKita")
                    .font(.title)
                    .bold()

                Text("いらっしゃいませ")
                    .multilineTextAlignment(.center)
                    .font(.headline)

                Text("Let’s practice real-life conversations!")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
        }
    }
}

#Preview {
    Welcome()
}

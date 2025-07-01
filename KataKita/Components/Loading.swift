//
//  Loading.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 17/06/25.
//

import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2)

            Text(message)
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    LoadingView(message: "Retrieving data...")
}

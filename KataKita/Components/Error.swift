//
//  Error.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 17/06/25.
//

import SwiftUI

struct ErrorView: View {
    var error: Error
    var onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            VStack(spacing: 8) {
                Text("There is an error")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }

            Button(action: {
                onRetry()
            }) {
                Text("Retry")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top, 16)
        }
        .padding()
    }
}

#Preview {
    ErrorView(
        error: NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tidak dapat terhubung ke server."]),
        onRetry: {
            print("Melakukan refresh...")
        }
    )
}

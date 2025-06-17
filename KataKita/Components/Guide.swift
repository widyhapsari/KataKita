//
//  Guide.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct Guide: View {
    var body: some View {
        VStack {
            Text("3/3")
                .font(.subheadline)
            
            Text("You're at a restaurant in Japan. You want to make sure your meal doesn't contain pork and alcohol.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding()
            
            NavigationLink(destination: {
                PracticeView()
            }, label: {
                HStack {
                    Image(systemName: "chevron.right")
                    
                    Text("Ask staff now")
                }
                .padding()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .background(.black)
                .cornerRadius(12)
            })
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        Guide()
    }
}

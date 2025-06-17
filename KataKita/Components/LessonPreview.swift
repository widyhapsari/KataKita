//
//  Words.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct LessonPreview: View {
    var body: some View {
        VStack (spacing: 20) {
            Text("Conversation 1")
                .font(.title)
                .foregroundStyle(.cyan)
                .fontWeight(.bold)
            
            VStack (spacing: 20) {
                Text("Practice asking about ingredients and stating your dietary needs")
                    .font(.body)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Get ready, you’ll crush these vocabularies")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            
            HStack (spacing: 20) {
                VStack {
                    Text("arukōru")
                        .font(.callout)
                        .fontWeight(.semibold)
                    
                    Image("Alcohol")
                    
                    Text("すみません")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                    
                    Text("alcohol")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                    
                    Circle()
                        .frame(width: 40, height: 40)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(12)
                .shadow(radius: 4)
                
                VStack {
                    Text("arukōru")
                        .font(.callout)
                        .fontWeight(.semibold)
                    
                    Image("Pork")
                    
                    Text("すみません")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                    
                    Text("alcohol")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                    
                    Circle()
                        .frame(width: 40, height: 40)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(12)
                .shadow(radius: 4)
            }
            
            NavigationLink {
                ScenarioView()
            } label: {
                VStack {
                    Text("Start")
                        .foregroundStyle(.white)
                        .fontWeight(.medium)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.cyan)
                .cornerRadius(12)
            }

        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(20)
    }
}

#Preview {
    NavigationStack {
        LessonPreview()
    }
}

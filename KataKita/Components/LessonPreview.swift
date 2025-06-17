//
//  Words.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct LessonPreview: View {
    @EnvironmentObject var viewModel: WelcomeViewModel
    
    let vocabs: [Vocab] = [
        Vocab(name: "ebi", image: "alcohol", nihongo: "エビ", english: "shrimp", audio_name: "shrimp.mp3"),
        Vocab(name: "kani", image: "pork", nihongo: "カニ", english: "crab", audio_name: "crab.mp3"),
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack (alignment: .bottom) {
            VStack {
                Image("kero")
                    .resizable()
                    .frame(width: 227, height: 195)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            VStack {
                Text("Conversation 1")
                    .font(.title)
                    .foregroundStyle(.cyan)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                VStack (spacing: 10) {
                    Text("Practice asking about ingredients and stating your dietary needs")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text("Get ready, you’ll crush these vocabularies")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom)
                
                LazyVGrid(columns: columns) {
                    ForEach(vocabs) { vocab in
                        VocabCard(
                            name: vocab.name,
                            image: vocab.image,
                            nihongo: vocab.nihongo,
                            english: vocab.english,
                            audio_name: vocab.audio_name
                        )
                        .environmentObject(viewModel)
                    }
                }
                .padding(.bottom, 25)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(12)
            .padding(.bottom, 45)
            
            NavigationLink {
                ScenarioView()
            } label: {
                ZStack {
                    Image("sign")
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: 60)
                    
                    Text("Start")
                        .font(.title2)
                        .foregroundStyle(.black)
                }
                .padding()
                .frame(width: 180, alignment: .bottom)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        LessonPreview()
    }
}

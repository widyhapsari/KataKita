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
        Vocab(name: "butaniku", image: "Pork", nihongo: "豚肉", english: "pork", audio_name: "pork.mp3"),
        Vocab(name: "arukoru", image: "Alcohol", nihongo: "アルコール", english: "alcohol", audio_name: "alcohol.mp3"),
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
                Text("Conversation #1: Order Halal Food")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
                
                VStack (spacing: 10) {
                    Text("Speak Up About What You Can’t Eat")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text("You’ll crush these vocabularies...")
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
                    Image("signSecondary")
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: 60)
                    
                    Text("START")
                        .font(.title2)
                        .foregroundStyle(.black)
                        .bold()
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
            .environmentObject(WelcomeViewModel())
    }
}

//
//  Cards.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 17/06/25.
//

import SwiftUI

struct VocabCard: View {
    let name: String
    let image: String
    let nihongo: String
    let english: String
    let audio_name: String
    
    @EnvironmentObject var viewModel: WelcomeViewModel
    
    var body: some View {
        VStack {
            Text(name)
                .font(.callout)
                .fontWeight(.semibold)
            
            Image(image)
            
            Text(nihongo)
                .font(.footnote)
                .foregroundStyle(.gray)
                .fontWeight(.semibold)
            
            Text(english)
                .font(.footnote)
                .foregroundStyle(.gray)
                .fontWeight(.semibold)
            
            Button {
                viewModel.playAudio(named: audio_name)
            } label: {
                VStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .resizable()
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(width: 20, height: 15)
                }
                .padding()
                .background(.white)
                .cornerRadius(1000)
                .shadow(radius: 2)
            }

        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

//
//  WordNodes.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//
import SwiftUI

struct WordNodes: View {
    let iWords: [Word] = [
        Word(romaji: "Sumimasen,", kana: "すみません"),
        Word(romaji: "Kono", kana: "この"),
        Word(romaji: "ryōri", kana: "料理"),
        Word(romaji: "ni", kana: "に"),
        Word(romaji: "butaniku", kana: "豚肉"),
        Word(romaji: "to", kana: "や"),
        Word(romaji: "arukōru", kana: "アルコール"),
        Word(romaji: "wa", kana: "は"),
        Word(romaji: "haitte", kana: "入って"),
        Word(romaji: "imasu", kana: "います"),
        Word(romaji: "ka?", kana: "か？")
    ]
    
    let columns = [GridItem(.adaptive(minimum: 80), spacing: 12)]
    
    var body: some View {
        VStack {
            Text("Ask this to the staff:")
                .font(.callout)
                .foregroundStyle(.gray)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                ForEach(iWords, id: \.romaji) { word in
                    WordBox(romaji: word.romaji, kana: word.kana)
                }
            }
            
            VStack {
                Button {
                    //
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .resizable()
                        .frame(width: 18, height: 14)
                        .padding()
                        .background(.white)
                        .cornerRadius(.infinity)
                        .shadow(radius: 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Text("🇬🇧: “Excuse me, does this food contain pork and alcohol?”")
                .font(.footnote)
                .foregroundStyle(.gray)
        }
        .padding()
    }
}

struct Word: Identifiable {
    var id: String { romaji }
    let romaji: String
    let kana: String
}

struct WordBox: View {
    let romaji: String
    let kana: String
    
    var body: some View {
        VStack {
            Text(romaji)
                .font(.callout)
                .fontWeight(.medium)
            
            Divider()
            
            Text(kana)
                .font(.footnote)
                .foregroundStyle(.gray)
        }
        .cornerRadius(8)
    }
}

#Preview {
    WordNodes()
}

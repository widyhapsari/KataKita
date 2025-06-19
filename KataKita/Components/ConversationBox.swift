//
//  ConversationBox.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct staffLine: Identifiable, Hashable {
    let id: UUID
    let staffRomaji: String
    let staffNihongo: String
    let staffEnglish: String
    let staffAudio: String

    init(id: UUID = UUID(), staffRomaji: String, staffNihongo: String, staffEnglish: String, staffAudio: String) {
        self.id = id
        self.staffRomaji = staffRomaji
        self.staffNihongo = staffNihongo
        self.staffEnglish = staffEnglish
        self.staffAudio = staffAudio
    }
}

let staffLines: [staffLine] = [
    staffLine(staffRomaji: "Kon'nichiwa. Nani o go chūmon sa remasu ka?", staffNihongo: "こんにちは。何をご注文されますか？", staffEnglish: "Hello, what would you like to order?", staffAudio: "staffline1.mp3"),
    staffLine(staffRomaji: "Hai, ebi ga haitte orimasu ga, kani wa tsukatte orimasen.", staffNihongo: "はい、エビが入っておりますが、カニは使っておりません。", staffEnglish: "Yes, it contains shrimp, but we don’t use crab.", staffAudio: "staffline2.mp3"),
    staffLine(staffRomaji: "Kashikomarimashita, Shōshō omachi kudasai.", staffNihongo: "かしこまりました, 少々お待ちください。", staffEnglish: "Certainly, Please wait a moment.", staffAudio: "staffline3.mp3"),
    staffLine(staffRomaji: "Eh? Sumimasen, mō ichido ii desu ka?", staffNihongo: "えっ？すみません、もう一度いいですか？", staffEnglish: "Huh? Sorry, could you say that again?", staffAudio: "staffline4.mp3")
    ]

struct ConversationBox: View {
    @EnvironmentObject var viewModel: WelcomeViewModel
    
    let line: staffLine
    
    var body: some View {
        VStack {
            Text(line.staffRomaji)
                .font(.footnote)
                .multilineTextAlignment(.center)
            
            Text(line.staffNihongo)
                .font(.caption2)
                .multilineTextAlignment(.center)
            
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 26, height: 26)
                    .blur(radius: 3)

                Button {
                    print(line.staffAudio)
                    viewModel.playAudio(named: line.staffAudio)
                } label: {
                    Image(systemName: "speaker.wave.2.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .font(.system(size: 28))
                }

            }
            
            Text(line.staffEnglish)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 184)
        .background(.white)
        .cornerRadius(16, corners: [.topLeft, .topRight, .bottomRight])
    }
}

#Preview {
    ConversationBox(line: staffLines[1])
        .environmentObject(WelcomeViewModel())
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

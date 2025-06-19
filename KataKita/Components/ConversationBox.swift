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

    init(id: UUID = UUID(), staffRomaji: String, staffNihongo: String, staffEnglish: String) {
        self.id = id
        self.staffRomaji = staffRomaji
        self.staffNihongo = staffNihongo
        self.staffEnglish = staffEnglish
    }
}

let staffLines: [staffLine] = [
    staffLine(staffRomaji: "Kon'nichiwa. Nani o go chūmon sa remasu ka?", staffNihongo: "こんにちは。何をご注文されますか？", staffEnglish: "Hello, what would you like to order?"),
    staffLine(staffRomaji: "Hai, ebi ga haitte orimasu ga, kani wa tsukatte orimasen.", staffNihongo: "はい、エビが入っておりますが、カニは使っておりません。", staffEnglish: "Yes, it contains shrimp, but we don’t use crab."),
    staffLine(staffRomaji: "Kashikomarimashita, Shōshō omachi kudasai.", staffNihongo: "かしこまりました, 少々お待ちください。", staffEnglish: "Certainly, Please wait a moment."),
    staffLine(staffRomaji: "Eh? Sumimasen, mō ichido ii desu ka?", staffNihongo: "えっ？すみません、もう一度いいですか？", staffEnglish: "Huh? Sorry, could you say that again?")
    ]

struct ConversationBox: View {
    let line: staffLine
    
    var body: some View {
        VStack {
            Text(line.staffRomaji)
                .font(.footnote)
                .multilineTextAlignment(.center)
            
            Text(line.staffNihongo)
                .font(.caption2)
                .multilineTextAlignment(.center)
            
            Circle()
                .frame(width: 28, height: 28)
            
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
    ConversationBox(line: staffLines[0])
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

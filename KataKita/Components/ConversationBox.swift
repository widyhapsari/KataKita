//
//  ConversationBox.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct ConversationBox: View {
    var body: some View {
        VStack {
            Text("Kon'nichiwa. Nani o go chūmon sa remasu ka?")
                .font(.footnote)
                .multilineTextAlignment(.center)
            
            Text("こんにちは。何をご注文されますか？")
                .font(.caption2)
                .multilineTextAlignment(.center)
            
            Circle()
                .frame(width: 28, height: 28)
            
            Text("Hello, what would you like to order?")
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
    ConversationBox()
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

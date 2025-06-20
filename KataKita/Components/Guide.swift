//
//  Guide.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct Guide: View {
    @Binding var currentPage: Int
    
    let overallPages: Int
    
    let words: [String] = [
        "You're at a restaurant in Japan. You want to make sure your meal doesn't contain pork or alcohol.",
        "Before ordering, you're about to ask the restaurant staff politely and clearly about the ingredients.",
        "Now, practice how you would say it in Japanese! Find out how well you nailed the pronunciation."
    ]
    
    var body: some View {
        VStack {
            Text("\(currentPage)/\(overallPages)")
                .font(.subheadline)
            
            Text(words[currentPage - 1])
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding()
                .bold()
            
            HStack {
                Button {
                    if currentPage > 1 {
                        currentPage = currentPage - 1
                    }
                } label: {
                    Image("back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .bottom)
                }
                .disabled(currentPage == 1 ? true : false)
                
                if currentPage == overallPages {
                    NavigationLink {
                        PracticeView(nextButton: false)
                    } label: {
                        Image(currentPage == overallPages ? "ready" :"next")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .bottom)
                    }

                } else {
                    Button {
                        if currentPage < overallPages {
                            currentPage = currentPage + 1
                        }
                    } label: {
                        Image(currentPage == overallPages ? "ready" :"next")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .bottom)
                    }
                }
            }
//=======
//            NavigationLink(destination: {
////                PracticeView()
//                QuizView()
//            }, label: {
//                HStack {
//                    Image(systemName: "chevron.right")
//
//                    Text("Ask staff now")
//                }
//                .padding()
//                .foregroundStyle(.white)
//                .frame(maxWidth: .infinity)
//                .background(.black)
//                .cornerRadius(12)
//            })
//>>>>>>> development
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        Guide(currentPage: .constant(1), overallPages: 5)
    }
}

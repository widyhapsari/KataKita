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
        "You're at a restaurant in Japan. You want to make sure your meal doesn't contain shrimp and crab.",
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
            
            HStack {
                Button {
                    if currentPage > 1 {
                        currentPage = currentPage - 1
                    }
                } label: {
                    Text("Prev")
                        .font(.title2)
                        .foregroundStyle(.black)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .background(
                            Image("sign")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 60)
                        )
                }
                .disabled(currentPage == 1 ? true : false)
                
                if currentPage == overallPages {
                    NavigationLink {
                        PracticeView(nextButton: false)
                    } label: {
                        Text(currentPage == overallPages ? "Ready!" :"Next")
                            .font(.title2)
                            .foregroundStyle(.black)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            .background(
                                Image("sign")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 60)
                            )
                    }

                } else {
                    Button {
                        if currentPage < overallPages {
                            currentPage = currentPage + 1
                        }
                    } label: {
                        Text(currentPage == overallPages ? "Ready!" :"Next")
                            .font(.title2)
                            .foregroundStyle(.black)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            .background(
                                Image("sign")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 60)
                            )
                    }
                }
            }
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

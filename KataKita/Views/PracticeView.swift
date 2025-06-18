//
//  PracticeView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct PracticeView: View {
    @State private var step = 0

    var value: Double {
        return 1/3
    }
    
    var body: some View {
        ZStack {
            Group {
                if step == 0 {
                    VStack {
                        CustomProgressView(value: 0.4)
                        
                        ZStack {
                            PracticeBG(waiter: "waiter1")
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    ConversationBox()
                                }
                                Spacer()
                            }
                            .padding(.top, 42)
                            .padding(.horizontal, 36)
                        }
                    }
                } else if step == 1 {
                    VStack {
                        CustomProgressView(value: 0.4)
                        
                        ZStack(alignment: .top) {
                            PracticeBG(waiter: "waiter1") // background stays still

                            // Top overlay
                            VStack {
                                HStack {
                                    Spacer()
                                    ConversationBox()
                                }
                                .padding(.top, 42)
                                .padding(.horizontal, 36)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                            // Bottom overlay
                            VStack {
                                Spacer() // Only pushes WordNodes
                                VStack {
                                    WordNodes()
                                }
                                .frame(maxWidth: .infinity, maxHeight: 320)
                                .background(.white)
                                .cornerRadius(32)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                }
            }
            if step < 1 {
                VStack {
                    Color.clear // Invisible view to attach .onAppear
                        .frame(height: 0)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                step += 1
                            }
                        }
                }
    //        } else {
    //            Button("Finish") {
    //                navigateToNextPage = true
    //            }
            }
        }
        .navigationTitle("Conversation 1")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    WelcomeView()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .font(.callout)
                        .foregroundStyle(.black)
                        .bold()
                }
                
            }
        }
    }
}

#Preview {
    NavigationStack {
        PracticeView()
    }
}

struct PracticeBG: View {
    var waiter: String = ""
    var body: some View {
        ZStack {
            VStack {
                Image("restaurant1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 420, height: 720, alignment: .top)
            }
            .frame(maxHeight: .infinity, alignment: .trailing)
            
            VStack {
                Image(waiter)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 600)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity )
        .padding(.vertical)
    }
}

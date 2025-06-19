//
//  PracticeView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct PracticeView: View {
    @State private var step = 0
    @State var nextButton: Bool = false // Added explicit default value
    var value: Double {
        return 1/3
    }
    
    var body: some View {
        ZStack {
                if step == 0 {
                    VStack {
                        CustomProgressView(value: 0.25)
                            .padding(.top, 42)
                        
                        ZStack {
                            PracticeBG(waiter: "waiter1")
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    if let firstLine = staffLines.first {
                                        ConversationBox(line: firstLine)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.top, 42)
                            .padding(.horizontal, 36)
                        }
                    }
                } else if step == 1 {
                    VStack {
                        CustomProgressView(value: 0.5)
                            .padding(.top, 42)
                        
                        ZStack(alignment: .top) {
                            PracticeBG(waiter: "waiter1") // background stays still

                            // Top overlay
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    if let firstLine = staffLines.first {
                                        ConversationBox(line: firstLine)
                                    }
                                }
                                .padding(.top, 42)
                                .padding(.horizontal, 36)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                            // Bottom overlay
                            VStack {
                                Spacer() // Only pushes WordNodes
                                VStack {
                                    WordNodes(nextButton: $nextButton, step: $step)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .background(.white)
                                .cornerRadius(32)
                                .padding(.bottom, 16)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                } else if step == 2 {
                    VStack {
                        CustomProgressView(value: 0.75)
                            .padding(.top, 42)
                        
                        ZStack {
                            PracticeBG(waiter: "waiter1")
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    if let secondLine = staffLines.dropFirst().first {
                                        ConversationBox(line: secondLine)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.top, 42)
                            .padding(.horizontal, 36)
                        }
                    }
                } else if step == 3 {
                    VStack {
                        CustomProgressView(value: 1)
                            .padding(.top, 42)
                        
                        ZStack(alignment: .top) {
                            PracticeBG(waiter: "waiter1") // background stays still

                            // Top overlay
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    if let firstLine = staffLines.dropFirst().first {
                                        ConversationBox(line: firstLine)
                                    }
                                }
                                .padding(.top, 42)
                                .padding(.horizontal, 36)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                            // Bottom overlay
                            VStack {
                                Spacer()
                                VStack {
                                    WordNodes(nextButton: $nextButton, step: $step)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .background(.white)
                                .cornerRadius(32)
                                .padding(.bottom, 16)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                }
            
            
            if step == 0 {
                VStack {
                    Color.clear // Invisible view to attach .onAppear
                        .frame(height: 0)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                step += 1
                            }
                        }
                }
            } else if step == 1 {
                VStack {
                    Spacer()
                    
                    if nextButton {
                        Button(action: {
                            print("🎯 Next button tapped at step \(step)")
                            nextButton = false // Reset for next interaction
                            step += 1
                        }) {
                            Text("Next")
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
                        .padding(.bottom, 42)
                    }
                }
            } else if step == 2 {
                VStack {
                    Color.clear // Invisible view to attach .onAppear
                        .frame(height: 0)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                nextButton = false // Reset nextButton before moving to step 3
                                step += 1
                            }
                        }
                }
            } else if step == 3 {
                // Add the Next button for step 3 as well
                VStack {
                    Spacer()
                    
                    if nextButton {
                        Button(action: {
                            print("🎯 Final Next button tapped at step \(step)")
                            // Handle completion - maybe navigate to next screen
                            nextButton = false
                            step += 1
                        }) {
                            Text("Finish")
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
                        .padding(.bottom, 42)
                    }
                }
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
        .onChange(of: nextButton) { newValue in
            print("🔄 PracticeView: nextButton changed to \(newValue) at step \(step)")
        }
    }
}

#Preview {
    NavigationStack {
        PracticeView(nextButton: false)
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

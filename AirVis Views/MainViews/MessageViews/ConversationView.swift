//
//  ConversationView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/21/24.
//

import SwiftUI
#if os(macOS)
struct ConversationView: View {
    var user: User
    @State private var textMessage = ""
    @FocusState private var isFocused: Bool 
    @State private var isHovering: Bool = false
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = false
                }
            VStack(spacing: 0){
                ChatView().environmentObject(appModel)
                
                HStack(spacing: 12) {
                    TextField("Enter Message", text: $textMessage)
                        .font(.system(size: 16))
                        .disableAutocorrection(true)
                        .background(Color.clear)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .onSubmit {
                            performSend()
                            isFocused = false
                        }.onChange(of: textMessage) { newValue in
                            if newValue.count > 100 {
                                textMessage = String(newValue.prefix(100))
                            }
                        }
                    
                    
                    
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                            .onTapGesture {
                                performSend()
                                isFocused = false
                            }
                            .opacity(textMessage.isEmpty ? 0 : 1)
                    
                }
                .onHover(perform: { nv in
                    isHovering = nv
                })
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 24).fill(Color.black.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(isFocused || isHovering ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                }
                .padding(5)
                
                .frame(maxWidth: .infinity)
                
                
            }
        }
#if os(iOS)
        .navigationTitle(user.username)
#endif
    }
    
    func performSend() {
        guard !textMessage.isEmpty else { return }
        
        appModel.sendMessage(messageText: textMessage, recipientID: user.id) {  error in
            if let error = error {
                print("Error starting conversation: \(error.localizedDescription)")
            } else {                
                textMessage = ""
//                                            print("Conversation started successfully!")
            }
        }
    }
}
#elseif os(iOS)
struct ConversationView: View {
    var user: User
    @State private var textMessage = ""
    @FocusState private var isFocused: Bool
    @State private var isHovering: Bool = false
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = false
                }
            VStack(spacing: 0){
                ChatView().environmentObject(appModel)
                HStack{
                    HStack(spacing: 12) {
                        TextField("Enter Message", text: $textMessage)
                            .font(.system(size: 18))
                            .disableAutocorrection(true)
                            .background(Color.clear)
                            .textFieldStyle(.plain)
                            .focused($isFocused)
                            .onSubmit {
                                //                            performSend()
                                isFocused = false
                            }.onChange(of: textMessage) { newValue in
                                if newValue.count > 100 {
                                    textMessage = String(newValue.prefix(100))
                                }
                            }
                        
                        
                        
                        
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 26))
                            .onTapGesture {
                                performSend()
                                isFocused = false
                            }
                            .opacity(textMessage.isEmpty ? 0 : 1)
                        
                    }
                    .onHover(perform: { nv in
                        isHovering = nv
                    })
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 24).fill(Color.black.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(isFocused || isHovering ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity)
                }.padding(.horizontal, 5)
                
            }
        }
#if os(iOS)
        .navigationTitle(user.username)
#endif
    }
    
    func performSend() {
        guard !textMessage.isEmpty else { return }
        
        appModel.sendMessage(messageText: textMessage, recipientID: user.id) {  error in
            if let error = error {
                print("Error starting conversation: \(error.localizedDescription)")
            } else {
                textMessage = ""
//                                            print("Conversation started successfully!")
            }
        }
    }
}
#endif

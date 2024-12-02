//
//  ChatView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/21/24.
//
import SwiftUI
import Firebase


#if os(macOS)
struct ChatView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var isAtTop: Bool = false // Tracks if the user scrolled to the top
    @State private var displayMessages: [Message] = []
    @State var lastLocalMessageDocumentSnapshot: DocumentSnapshot? = nil
    @State var endOfMessage: Bool = false
    @State private var debounceTimer: Timer? = nil // Timer for debouncing
       
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack
                    {
                        if(!endOfMessage && displayMessages.count > 19)
                        {
                            Button(action: {
                                loadMoreMessages()
                            })
                            {
                                Image(systemName: "chevron.up.circle")
                            }
                            
                            .buttonStyle(PlainButtonStyle())
                        }
                        // Display chat messages
                        ForEach(Array(displayMessages)) { message in
                            HStack {
                                if message.senderID == appModel.user.id {
                                    Spacer()
                                    MessageBubble(message: message.text, isFromCurrentUser: true)
                                } else {
                                    MessageBubble(message: message.text, isFromCurrentUser: false)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .id(message.id)
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .defaultScrollAnchor(.bottom)
                .listStyle(PlainListStyle())
                .padding(.top,5)
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: appModel.currentMessages) { _,_ in
                    scrollToBottom(proxy: proxy)
                }
            }
        }
        
        .onAppear{
            displayMessages = appModel.currentMessages
            lastLocalMessageDocumentSnapshot = appModel.lastMessageDocumentSnapshot
        }
        .onChange(of: appModel.currentMessages) { _,_ in
            displayMessages = appModel.currentMessages
            lastLocalMessageDocumentSnapshot = appModel.lastMessageDocumentSnapshot
        }
    }

    
    func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let lastMessage = displayMessages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
    }

    func loadMoreMessages() {

                
        appModel.fetchMessages(for: appModel.activeConversationID, limit: 10, lastDocument: lastLocalMessageDocumentSnapshot) { messages, lastDocument, error in
                
                if let error = error {
                    print("Error fetching older messages: \(error)")
                    return
                }
                
                if let messages = messages {
                    // Prepend messages to UI
                    displayMessages.insert(contentsOf: messages, at: 0)
                }
                
                if lastDocument == nil {
                    print("No more older messages to load.")
                    endOfMessage = true
                }
                
                lastLocalMessageDocumentSnapshot = lastDocument
                
            }
        

    }
    
    
}
#endif

struct MessageBubble: View {
    let message: String
    let isFromCurrentUser: Bool

    var body: some View {
        Text(message)
            .padding(10)
            .foregroundColor(isFromCurrentUser ? .white : .black)
            .background(isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
            .cornerRadius(12)
            .frame(maxWidth: 250, alignment: isFromCurrentUser ? .trailing : .leading)
    }
}



#if os(iOS)
struct ChatView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var isAtTop: Bool = false // Tracks if the user scrolled to the top
    @State private var displayMessages: [Message] = []
    @State var lastLocalMessageDocumentSnapshot: DocumentSnapshot? = nil
    @State var endOfMessage: Bool = false
    @State private var debounceTimer: Timer? = nil // Timer for debouncing
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    var body: some View {
        VStack {
            

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack
                    {
                        if(!endOfMessage && displayMessages.count > 19)
                        {
                            Button(action: {
                                loadMoreMessages()
                            }) {
                                Image(systemName: "chevron.up.circle")
                            }
                            
                            .buttonStyle(PlainButtonStyle())
                        }
                        // Display chat messages
                        ForEach(Array(displayMessages)) { message in
                            HStack {
                                if message.senderID == appModel.user.id {
                                    Spacer()
                                    MessageBubble(message: message.text, isFromCurrentUser: true)
                                } else {
                                    MessageBubble(message: message.text, isFromCurrentUser: false)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .id(message.id)
                        }
                        .listRowSeparator(.hidden)
                       
                    }.padding(0)
                    Divider()
                        .id("goBottom")
//                        .scaleEffect(0.001)
//                        .hidden()
//                        .padding(0)
//                        .contentMargins(0)
                }
                .environment(\.defaultMinListRowHeight, 0)
                .defaultScrollAnchor(.bottom)
                .listStyle(PlainListStyle())
                .padding(.top,5)
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: appModel.currentMessages) { _,_ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: keyboardObserver.isKeyboardVisible) { _,nv in
                    if(nv)
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                        {
                            withAnimation{
                                proxy.scrollTo("goBottom", anchor: .bottom)
                            }
                        }
                    }
                    else
                    {
                        withAnimation{
                            proxy.scrollTo("goBottom", anchor: .bottom)
                        }
                    }
                }
            }
            
        }

        
        .padding(.bottom, 5) // Space for the message input bar
        .onAppear{
            displayMessages = appModel.currentMessages
            lastLocalMessageDocumentSnapshot = appModel.lastMessageDocumentSnapshot
        }
        .onChange(of: appModel.currentMessages) { _,_ in
            displayMessages = appModel.currentMessages
            lastLocalMessageDocumentSnapshot = appModel.lastMessageDocumentSnapshot
        }
        
    }

    
    func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let lastMessage = displayMessages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
    }

    func loadMoreMessages() {
        
        
        
        appModel.fetchMessages(for: appModel.activeConversationID, limit: 10, lastDocument: lastLocalMessageDocumentSnapshot) { messages, lastDocument, error in
                
                if let error = error {
                    print("Error fetching older messages: \(error)")
                    return
                }
                
                if let messages = messages {
                    // Prepend messages to UI
                    displayMessages.insert(contentsOf: messages, at: 0)
                }
                
                if lastDocument == nil {
                    print("No more older messages to load.")
                    endOfMessage = true
                }
                
                lastLocalMessageDocumentSnapshot = lastDocument
                
            }
        

    }
    
    
}

#endif

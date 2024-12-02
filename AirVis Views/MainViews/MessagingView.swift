//
//  Messagingview.swift
//  AirVis
//
//  Created by Arun Kurian on 11/21/24.
//

import SwiftUI




#if os(macOS)
struct MessagingView: View {
    @EnvironmentObject var appModel: AppModel
    @State var resultNumber = 14
    @State var isTapEnabled: Bool = false
    @State var isAuthorPresented: Bool = false
    @State var presentingChatBox: Bool = false
    @State var activeConversationID: String = ""
    @State var activeUser = User(id: "")
    @State var localConversation : [Conversation] = []
    @State var isNotification: Bool = false
    
    var body: some View {
        

        ZStack{
            
            if(appModel.conversations.isEmpty)
            {
                
                Text("No Conversations")
                
            }
            else
            {
                HStack{
                        VStack(alignment: .leading){
                            HStack(spacing: 20){
                             
                                    Text("Messages")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray)
                                        .padding(.leading, 30)
                                        .transition(.scale)
                             
                                Spacer()
                                Button {
                                    withAnimation {                                    
                                        isNotification.toggle()
                                    }
                                } label: {
                                    Image(systemName: "bell.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray)
                                      
                                }
                                .buttonStyle(.plain)
                                

                            }
                            .sheet(isPresented: $isNotification) {
                                NotificationView(isPresented: $isNotification).environmentObject(appModel)
                            }

                                .padding(.top, 20)
                                .frame(width: 300)
                            
                            List{
                                ForEach(appModel.conversations) { conversation in
                                    
                                    if let otherParticipantID = conversation.participants.first(where: { $0 != appModel.user.id }),
                                       let user = appModel.conversationUsers.first(where: { $0.id == otherParticipantID })
                                    {
                                        ConversationRowView(user: user, conversation: conversation, userSelfID: appModel.user.id )
                                            .listRowInsets(EdgeInsets())
                                            .onTapGesture {
                                                if isTapEnabled {
                                                    activeConversationID = conversation.id
                                                    appModel.activeConversationID = conversation.id
                                                    activeUser = user
                                                    isAuthorPresented = true
                                                }
                                            }
                                    } else {
                                        // Show a placeholder if no user is found
                                        Text("Unknown User").foregroundColor(.gray)
                                    }
                                }
                                .onAppear {
                                    // Enable tap gesture after 1 second
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        isTapEnabled = true
                                    }
                                }
                                .listRowSeparator(.hidden)
                            }
                            .listStyle(PlainListStyle())
                            .frame(width: 300)
                            
                        }
                        Divider()
                    
                    Spacer()
                    if(!isAuthorPresented)
                    {
                        Text("Select a conversation")
                    }
                    else
                    {
                        if(presentingChatBox)
                        {
                            ConversationView(user: activeUser).environmentObject(appModel)
                        }
                        else
                        {
                            ProgressView().onAppear{
                                
                                // Fetch messages and set up listener
                                appModel.fetchMessages(for: activeConversationID, limit: 20, lastDocument: nil) { messages, lastDoc, error in
                                    if let messages = messages {
                                        
                                        appModel.resetUnreadCounts(conversationID: activeConversationID)
                                        {result in
                                            switch result {
                                                               case .success(let successMessage):
                                                
                                                if let index = appModel.conversations.firstIndex(where: { $0.id == activeConversationID }) {
                                                       // Check if the unreadCounts for the userID exists
                                                    if appModel.conversations[index].unreadCounts[appModel.user.id] != nil {
                                                           appModel.conversations[index].unreadCounts[appModel.user.id] = 0
                                                       }
                                                   }
                                                               case .failure(let error):
                                                                   print( "Error: \(error.localizedDescription)")
                                                               }
                                            
                                        }
                                        // Reverse the messages for correct chronological order
                                        appModel.currentMessages = messages.reversed()
                                        appModel.lastMessageDocumentSnapshot = lastDoc
                                        presentingChatBox = true

                                        // Get the timestamp of the most recent message
                                        if let lastMessageTimestamp = messages.first?.timestamp {
                                            // Start listening for new messages after the most recent one fetched
                                            appModel.startListeningForNewMessages(for: activeConversationID, after: lastMessageTimestamp) { newMessages, error in
                                                if let newMessages = newMessages, !newMessages.isEmpty {
                                                    for newMessage in newMessages {
                                                        if !appModel.currentMessages.contains(where: { $0.id == newMessage.id }) {
                                                            appModel.currentMessages.append(newMessage)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }


                            }


                            }
                        }
                    }
                    Spacer()
                    }
            }
        }.onChange(of: activeConversationID) { ov, newValue in
            appModel.messageListener?.remove()
            appModel.currentMessages.removeAll()
            presentingChatBox = false
        }

        
        
      

        

    }
    }
#endif


#if os(iOS)
struct MessagingView: View {
    
    @EnvironmentObject var appModel: AppModel
    @State var resultNumber = 14
    @State var isTapEnabled: Bool = false
    @State var isAuthorPresented: Bool = false
    @State var presentingChatBox: Bool = false
    @State var activeConversationID: String = ""
    @State var activeUser = User(id: "")
    @State var localConversation : [Conversation] = []
    @State private var path = NavigationPath()
    @State var isNotification: Bool = false
    @State var fetched: Bool = false
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading) {
                if appModel.conversations.isEmpty {
                    Text("No Conversations")
                } else {
                    VStack(alignment: .leading) {
                        List {
                            ForEach(appModel.conversations) { conversation in
                                if let otherParticipantID = conversation.participants.first(where: { $0 != appModel.user.id }),
                                   let user = appModel.conversationUsers.first(where: { $0.id == otherParticipantID }) {
                                    Button {
                                        path.append(user)
                                        
                                        
                                        // Fetch messages and set up listener
                                        appModel.fetchMessages(for: conversation.id, limit: 20, lastDocument: nil) { messages, lastDoc, error in
                                            if let messages = messages {
                                                
                                                appModel.resetUnreadCounts(conversationID: conversation.id)
                                                {result in
                                                    switch result {
                                                                       case .success(let successMessage):
                                                        
                                                        if let index = appModel.conversations.firstIndex(where: { $0.id == conversation.id }) {
                                                               // Check if the unreadCounts for the userID exists
                                                            if appModel.conversations[index].unreadCounts[appModel.user.id] != nil {
                                                                   appModel.conversations[index].unreadCounts[appModel.user.id] = 0
                                                               }
                                                           }
                                                        decreaseBadgeCount() // because any unread message is set as 1 badge and is not updated in unreadCount of user in server.
                                                                       case .failure(let error):
                                                                           print( "Error: \(error.localizedDescription)")
                                                                       }
                                                    
                                                }
                                                // Reverse the messages for correct chronological order
                                                appModel.currentMessages = messages.reversed()
                                                appModel.lastMessageDocumentSnapshot = lastDoc
                                                
                                                // Get the timestamp of the most recent message
                                                if let lastMessageTimestamp = messages.first?.timestamp {
                                                    // Start listening for new messages after the most recent one fetched
                                                    appModel.startListeningForNewMessages(for: conversation.id, after: lastMessageTimestamp) { newMessages, error in
                                                        if let newMessages = newMessages, !newMessages.isEmpty {
                                                            for newMessage in newMessages {
                                                                if !appModel.currentMessages.contains(where: { $0.id == newMessage.id }) {
                                                                    appModel.currentMessages.append(newMessage)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        ConversationRowView(user: user, conversation: conversation, userSelfID: appModel.user.id )
                                            .listRowInsets(EdgeInsets())
                                    }
                                } else {
                                    Text("Unknown User").foregroundColor(.gray)
                                }
                            }
                            .listRowSeparator(.hidden)
                            .onAppear {
                                // Enable tap gesture after 1 second
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    isTapEnabled = true
                                }
                            }
                           
                            
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .onAppear {
                localConversation = appModel.conversations
            }
            .fullScreenCover(isPresented: $isNotification) {
                NotificationView(isPresented: $isNotification).environmentObject(appModel)
            }
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbar(content: {
                
                ToolbarItem(placement: .principal) {
                                       Text("Messages")
                        .font(.system(size: 20, weight: .medium))
                        .onChange(of: scenePhase) { op, newPhase in
                                       if newPhase == .inactive {
//                                           appModel.enableMessageNotificationsTemp()
                                       } else if newPhase == .active {
//                                           appModel.disableMessageNotificationsTemp()
                                       } else if newPhase == .background {
                                           appModel.enableMessageNotificationsTemp()
                                       }
                                   }
                        .onAppear {
                            appModel.disableMessageNotificationsTemp()
                        }
                        .onDisappear {
                            appModel.enableMessageNotificationsTemp()
                        }
                                   }
                // Bell icon at the trailing end
                                   ToolbarItem(placement: .navigationBarTrailing) {
                                       ZStack{
                                           Button(action: {
                                               
                                                   isNotification.toggle()
                                               
                                           }) {
                                               Image(systemName: "bell")
                                                   .font(.system(size: 17, weight: .regular))
                                                   .foregroundColor(.blue)
                                           }
                                           if(fetched)
                                           {
                                               if appModel.unreadCount > 0 && appModel.unreadCount < 100 {
                                                   Circle()
                                                       .fill(Color.red)
                                                       .frame(width: 15, height: 15)
                                                       .overlay(
                                                        Text("\(appModel.unreadCount)")
                                                            .font(.caption2)
                                                            .foregroundColor(.white)
                                                       )
                                                       .offset(x: 10, y: -10) // Position the badge
                                               }
                                               
                                               if appModel.unreadCount > 99 {
                                                   Circle()
                                                       .fill(Color.red)
                                                       .frame(width: 15, height: 15)
                                                       .offset(x: 10, y: -10) // Position the badge
                                               }
                                           }
                                       }
                                   }
                
                
            })
            .navigationDestination(for: User.self) { user in
                ConversationView(user: user)
                    .environmentObject(appModel)
                    .onAppear {
                        appModel.messageListener?.remove()
                        appModel.currentMessages.removeAll()
                        presentingChatBox = false
                    }
            }
        }
        .onDisappear {
            path = NavigationPath()
           }
        .onAppear {
            fetched = false
            appModel.fetchUserData(userId: appModel.user.id) { _ in
                fetched = true
            }
        }
      
        
    }
}
#endif




#if os(macOS)

struct ConversationRowView: View {
    let user: User
    let conversation: Conversation
    let userSelfID: String
    @State var isHovering: Bool = false
    
    var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 2)
                
                HStack{
                    // Profile picture, using a placeholder if the profilePicture URL is empty
                                        HStack{
                            AsyncImageView(
                                urlString: user.profilePicture,
                                placeholder: Image("icon")
                            )
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            VStack(alignment: .leading){
                                Text(user.username)
                                    .font(.system(size: 14)) //
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 2)
                                    .padding(.top, 2)
                                if let unreadCount = conversation.unreadCounts[userSelfID], unreadCount > 0 {
                                    
                                        Text(conversation.lastMessage)
                                            .font(.system(size: 15)) //
                                            .padding(.horizontal, 2)
                                            .fontWeight(.medium)
                                            .foregroundColor(.black)
                                } else {
                                    
                                        Text(conversation.lastMessage)
                                            .font(.system(size: 12)) //
                                            .padding(.horizontal, 2)
                                            .foregroundColor(.black)
                                }
                                
                            }
                        
                    }
                    .padding()
                                  
                    
                    Spacer()
                    
                }

                
            }
//#if os(iOS)
//                    .frame(maxWidth: 400)
//#endif
            
            .scaleEffect(isHovering ? 0.95 : 0.9)
            .onHover { hovering in
                withAnimation {
                    isHovering = hovering
                }
            }
        }
}

#endif



#if os(iOS)
struct ConversationRowView: View {
    let user: User
    let conversation: Conversation
    let userSelfID: String
    @State var isHovering: Bool = false
    
    var body: some View {
//        ZStack{
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.white)
//                .shadow(color: Color.black.opacity(0.2), radius: 2)
            HStack{
                // Profile picture, using a placeholder if the profilePicture URL is empty
                HStack(alignment: .top, spacing: 10){
                    AsyncImageView(
                        urlString: user.profilePicture,
                        placeholder: Image("icon")
                    )
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1)).padding(.leading)
                    VStack(alignment: .leading){
                        Text(user.username)
                            .font(.system(size: 18, weight: .medium)) //
                            .foregroundColor(.blue)
                        if let unreadCount = conversation.unreadCounts[userSelfID], unreadCount > 0 {
                            
                                Text(conversation.lastMessage)
                                    .font(.system(size: 18)) //
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                        } else {
                            
                                Text(conversation.lastMessage)
                                    .font(.system(size: 14)) //
                                    .foregroundColor(.black)
                        }
                      
                        
                    }.padding(0)
                }
                Spacer()
                
            }
            
//        }
            
        }
}
#endif

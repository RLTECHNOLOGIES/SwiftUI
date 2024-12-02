//
//  NotificationView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/23/24.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var appModel : AppModel
    @Binding var isPresented: Bool
    @State var isSettingsPresented: Bool = false
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Example: "Nov 24, 2024"
        formatter.timeStyle = .short // Example: "1:15 PM"
        return formatter
    }()
    @State var userSheetPresented = false

    var body: some View {
#if os(macOS)
        VStack {
            
                VStack(spacing: 0){
                    // Header with back button and sign out
                    HStack {
                        Button {
                            withAnimation(.snappy(duration: 0.5)) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                        }
                        .buttonStyle(.plain)
                        .padding()
                        Spacer()
                        Text("Notifications")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.blue)
                            .padding(.vertical)
                        Spacer()
                        Button {
                            withAnimation(.snappy(duration: 0.5)) {
//                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "gear").foregroundStyle(Color.blue)
                        }
                        
                        .opacity(0)
                        .buttonStyle(.plain)
                        .padding()
                        
                        
                    }
                    
                    if(!appModel.user.notifications.isEmpty)
                    {
                        List(appModel.user.notifications, id: \.self) { notification in
                            HStack{
                                VStack(alignment: .leading) {
                                    Text(notification.message)
                                        .font(.system(size: 15))
                                    //                                    .font(notification.read ? .body : .headline)
                                    
                                    Text(dateFormatter.string(from: notification.timestamp))
                                        .foregroundColor(.gray).font(.system(size: 10)).padding(.top,10)
                                }
                                .frame(minHeight: 50)
                                Spacer()
                            }.sheet(isPresented: $userSheetPresented, content: {
                                AuthorView(userID:notification.userID, isPresented: $userSheetPresented).environmentObject(appModel).frame(width: 800, height: 800)
                                    
                            })
                            .padding(5)
                            .background(
                                   RoundedRectangle(cornerRadius: 10) // Background shape
                                    .fill(.gray.opacity(0.05)) // Background color
                                       .shadow(radius: 2) // Optional shadow for depth
                               )
                            .onTapGesture {
                                if(notification.type == "comment" || notification.type == "upvote" || notification.type == "favorite")
                                {
                                    DispatchQueue.main.async {
                                        isPresented = false
                                        
                                        appModel.getFile(withID: notification.fileID ?? "") { file in
                                            if let file = file {
                                                appModel.activeDisplayFile = file
                                                appModel.fileView = true
                                            } else {
                                                //                        self.showAlert(message: "Unable to retrieve the file.")
                                            }
                                        }
                                    }
                                }
                                
                                else if(notification.type == "follow")
                                {
                                    
                                    
                                    if(!notification.userID.isEmpty)
                                    {
                                        userSheetPresented = true
                                    }
                                    
                                }
                            }
                        }

                    }
                    else
                    {
                        Spacer()
                        Text("No Notifications").font(.title) .foregroundColor(.gray).padding(.leading,10)
                        Spacer()
                    }
                }
                
                
            
        }
        .frame(width: 450, height: 500, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.5), lineWidth: 0.3)
        )
        
#elseif os(iOS)
        
        
        VStack {
            
                VStack(spacing: 0){
                    // Header with back button and sign out
                    HStack {
                        Button {
                            withAnimation(.snappy(duration: 0.5)) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                        }
                        .buttonStyle(.plain)
                        .padding()
                        Spacer()
                        Text("Notifications")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.blue)
                            .padding(.vertical)
                        Spacer()
                        Button {
                            withAnimation(.snappy(duration: 0.5)) {
                                isSettingsPresented.toggle()
                            }
                        } label: {
                            Image(systemName: "gear").foregroundStyle(Color.blue)
                        }
                        .buttonStyle(.plain)
                        .padding()
                        
                        
                    }
                    Divider()
                    Spacer()
                    if(!appModel.user.notifications.isEmpty)
                    {
                        List(appModel.user.notifications, id: \.self) { notification in
                            VStack(alignment: .leading) {
                                Text(notification.message)
                                    .font(.system(size: 15))
//                                    .font(notification.read ? .body : .headline)
                                
                                Text(dateFormatter.string(from: notification.timestamp))
                                    .foregroundColor(.gray).font(.system(size: 10))
                            }.frame(minHeight: 50)
                                .fullScreenCover(isPresented: $userSheetPresented, content: {
                                    AuthorView(userID:notification.userID, isPresented: $userSheetPresented).environmentObject(appModel)
                                        
                                })
                            .onTapGesture {
                                if(notification.type == "comment" || notification.type == "upvote" || notification.type == "favorite")
                                {
                                    DispatchQueue.main.async {
                                        isPresented = false
                                        
                                        appModel.getFile(withID: notification.fileID ?? "") { file in
                                            if let file = file {
                                                appModel.activeDisplayFile = file
                                                appModel.fileView = true
                                            } else {
                                                //                        self.showAlert(message: "Unable to retrieve the file.")
                                            }
                                        }
                                    }
                                }
                                
                                else if(notification.type == "follow")
                                {
                                    
                                    
                                    if(!notification.userID.isEmpty)
                                    {
                                        userSheetPresented = true
                                    }
                                    
                                }
                                    
                            }
                            
                        }.listStyle(PlainListStyle())

                    }
                    else
                    {
                        Text("No Notifications").font(.title) .foregroundColor(.gray).padding(.leading,10)
                    }
                    Spacer()
                }.onAppear {
                    updateBadgeCount(to: 0)
                    appModel.unreadCount = 0
                    appModel.setUnreadCount(unreadCount: 0)
                    { _ in
//                                  print("Reset Notification")
                    }
                }
                .sheet(isPresented: $isSettingsPresented) {
                    NotificationPreferencesView().environmentObject(appModel)
                        .presentationDetents([.height(300)])
                        .presentationDragIndicator(.hidden)
                }

                
                
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        
#endif
    }
    
}


struct NotificationPreferencesView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var updatedPreferences: [String: Bool] = [:] // Track updates locally

    var body: some View {
        Form {
            Section(header: Text("Notification Preferences")) {
                Toggle("Likes Notifications", isOn: Binding(
                    get: { appModel.user.likesNotifications },
                    set: { value in
                        appModel.user.likesNotifications = value
                        updatedPreferences["likesNotifications"] = value
                    }
                ))

                Toggle("Comments Notifications", isOn: Binding(
                    get: { appModel.user.commentsNotifications },
                    set: { value in
                        appModel.user.commentsNotifications = value
                        updatedPreferences["commentsNotifications"] = value
                    }
                ))

                Toggle("Favorites Notifications", isOn: Binding(
                    get: { appModel.user.favoritesNotifications },
                    set: { value in
                        appModel.user.favoritesNotifications = value
                        updatedPreferences["favoritesNotifications"] = value
                    }
                ))
                Toggle("Follow Notifications", isOn: Binding(
                    get: { appModel.user.followNotifications },
                    set: { value in
                        appModel.user.followNotifications = value
                        updatedPreferences["followNotifications"] = value
                    }
                ))

                Toggle("Message Notifications", isOn: Binding(
                    get: { appModel.user.messageNotifications },
                    set: { value in
                        appModel.user.messageNotifications = value
                        updatedPreferences["messageNotifications"] = value
                    }
                ))
            }
        }
        .navigationTitle("Notifications")
        .onDisappear {
            // Update all changes in Firestore when the view disappears
            if !updatedPreferences.isEmpty {
                appModel.updatePreferences(updatedPreferences)
            }
        }
    }
}


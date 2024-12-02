//
//  AuthorView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/12/24.
//
import SwiftUI

struct AuthorView: View {
    var userID: String
    @Binding var isPresented: Bool
    @EnvironmentObject var appModel: AppModel
    @State var columns: [GridItem] = []
    @State var appears: Bool = false
    @State private var showPopover = false
    @State var expandHover: Bool = false
    @State var followIsActive = false
    @State var isLoading: Bool = true
    var body: some View {
#if os(macOS)
        ZStack {
            
            if isLoading
            {
                ProgressView()
            }
        
        GeometryReader { geometry in
            if(!isLoading)
            {
                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        HStack {
                            HStack{
                            Button {
                                    isPresented = false
                                    appModel.inAuthorProfile = false
                                
                            } label: {
                                Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                            }
                            .buttonStyle(.plain)
                            .padding()
                            .background(Color.white)
                            }
                            .onTapGesture {
                                        isPresented = false
                                        appModel.inAuthorProfile = false
                            }
                            .onDisappear {
                                appModel.inAuthorProfile = false
                            }
                            Spacer()
                            HStack{
                                Button {
                                    showPopover.toggle()
                                    
                                } label: {
                                    Image(systemName: "ellipsis.circle").font(.system(size:15)).foregroundStyle(Color.blue)
                                }
                                .buttonStyle(.plain)
                                .popover(isPresented: $showPopover, arrowEdge: .bottom)
                                {
                                    PopOverAuthorView(isPresented: $isPresented, followActive: $followIsActive).environmentObject(appModel)
                                }
                                
                                .onHover { expandHover in
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        self.expandHover = expandHover
                                    }
                                }
                                
                            }.padding()
                            
                        }
                        .padding(0)
                        
                        VStack(spacing: 0) {
                            VStack() {
                                
                                    HStack {
                                        if let image = appModel.authorProfileImage {
                                            Image(nsImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                                .shadow(radius: 5)
                                                .padding(0)
                                        } else {
                                            Image("icon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 150, height: 150)
                                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                                                .shadow(radius: 5)
                                                .padding(0)
                                        }
                                        VStack(alignment: .leading){
                                            Text(appModel.authorUser.username)
                                                .font(.system(size: 20,weight: .regular))
                                                .foregroundStyle(.gray)
                                            Text(appModel.authorUser.bio)
                                                .font(.caption)
                                                .padding(.leading, 1)
                                        }.padding(.leading)
                                    }
                                    .padding(20)
                                
                            }
                            
                            if !appModel.authorUploadedFiles.isEmpty {
                                List {
                                    Group {
                                        LazyVGrid(columns: columns, spacing: 20) {
                                            ForEach(Array(appModel.authorUploadedFiles.enumerated()), id: \.offset) { index, file in
                                                FileView(file: file).environmentObject(appModel)
                                            }
                                        }
                                        
                                        .padding(10)
                                    }
                                    .padding()
                                    .opacity(appears ? 1 : 0)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.gray.opacity(0.05))
                                )
                            }
                            else
                            {
                                HStack
                                {
                                    Spacer()
                                    Text("No files uploaded").font(.title2)
                                    Spacer()
                                }
                                    .frame(width: 800, height: 500)
                            }
                        }
                    }
                }
                .onAppear {
                    columns = calculateGridColumns(for: geometry.size.width)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.smooth(duration: 1)) {
                            appears = true
                        }
                    }
                }
                .onChange(of: geometry.size.width) { _,newWidth in
                    withAnimation(.smooth(duration: 1)) {
                        columns = calculateGridColumns(for: geometry.size.width)
                        //                    appears = true
                    }
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.5), lineWidth: 0.1)
                )
            }
                
            else
            {
//                ProgressView()
            }
        }
        }
        .onAppear{
          
            appModel.inAuthorProfile = true
            appModel.fetchAuthorUserData(userId: userID) { success in
                if success
                {
                    appModel.getAuthorUploadedFiles(userID: userID){ result in
                        
                        switch result
                        {
                            
                            
                        case .success(let files):
                            appModel.isFollowActive() { result in
                                switch result {
                                case .success(let isActive):
                                    followIsActive = isActive
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation {
                                            isLoading = false
                                        }
                                    }
                                    
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                 
                                }
                            }
                            
                            
                        case .failure(let error):
                              print("Failed to fetch files: \(error.localizedDescription)")
                              // Handle the error, like showing an alert to the user
                            
                        }
                        
                        
                        
                    }
                    
                } else {
                    print("Failed to fetch Author user data.")
                    isLoading = false
                    
                }
            }
            
        }
        
#elseif os(iOS)
        
        GeometryReader { geometry in
            if(!isLoading)
            {
                
                VStack(spacing: 0) {
                    VStack{
                        
                        VStack(spacing: 0) {
                            VStack(spacing: 0){
                                    HStack {
                                        Button {
                                            withAnimation {
                                                
                                                isPresented = false
                                                appModel.inAuthorProfile = false
                                            }
                                            
                                        } label: {
                                            Image(systemName: "chevron.left")
                                        } .onDisappear {
                                            appModel.inAuthorProfile = false
                                        }
                                        //                            .buttonStyle(ElevatedButtonStyle(labelColor: .gray, backgroundColor: .white, padding: 5))
                                        .padding()
                                        
                                        Spacer()
                                        HStack{
                                            Button {
                                                showPopover.toggle()
                                                
                                            } label: {
                                                Image(systemName: "ellipsis.circle").font(.system(size:15))
                                            }
                                            .sheet(isPresented: $showPopover) {
                                                PopOverAuthorView(isPresented: $isPresented, followActive: $followIsActive)
                                                    .environmentObject(appModel)
                                                    .presentationDetents([.height(175)])
                                                    .presentationDragIndicator(.hidden) // Adds a drag indicator to allow user to swipe down to dismiss
                                            }
                                            .onHover { expandHover in
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    self.expandHover = expandHover
                                                }
                                            }
                                            
                                        }.padding()
                                        
                                    }.padding(.top,10)
                                    
                                    HStack {
                                        if let image = appModel.authorProfileImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                                .shadow(radius: 5)
                                                .padding(0)
                                        } else {
                                            Image("icon")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                                                .shadow(radius: 5)
                                                .padding(0)
                                        }
                                        VStack(alignment: .leading){
                                            Text(appModel.authorUser.username)
                                                .font(.system(size: 18,weight: .medium))
                                                .foregroundStyle(.blue)
                                            Text(appModel.authorUser.bio)
                                                .padding(.leading, 1)
                                            
                                        }.padding(.leading,2)
                                    }
                                    .padding(.bottom,10)
                                    .padding(.top,-20)
                            }
                            .padding(.top, -10)
                            .frame(maxWidth: .infinity)
                            
                            .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.black.opacity(0.5), lineWidth: 0.1)
                                                .padding(.bottom, -5)
                                        )
                            if !appModel.authorUploadedFiles.isEmpty {
                                List {
                                    Group {
                                        LazyVGrid(columns: columns, spacing: 20) {
                                            ForEach(Array(appModel.authorUploadedFiles.enumerated()), id: \.offset) { index, file in
                                                FileView(file: file).environmentObject(appModel)
                                            }
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                    .opacity(appears ? 1 : 0)
                                }
                                .padding(5)
                                .listStyle(.plain)
                                
                            }
                            else
                            {
                                HStack
                                {
                                    Spacer()
                                    Text("No files uploaded").font(.title2).foregroundStyle(.gray)
                                    Spacer()
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                            }
                        }
                    }
                }
                .onAppear {
                    if(appModel.authorUploadedFiles.count > 1)
                    {
                        columns = calculateGridColumns(for: geometry.size.width)
                    }
                    else
                    {
                        columns = [GridItem(.flexible())]
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.smooth(duration: 1)) {
                            appears = true
                        }
                    }
                    
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.5), lineWidth: 0.1)
                )
                
            }
            
            else
            {
                ProgressView().onAppear{
                    
                    appModel.inAuthorProfile = true
                    appModel.fetchAuthorUserData(userId: userID) { success in
                        if success
                        {
                            appModel.getAuthorUploadedFiles(userID: userID){ result in
                                switch result
                                {
                                case .success(let files):
                                    appModel.isFollowActive() { result in
                                        switch result {
                                        case .success(let isActive):
                                            followIsActive = isActive
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                withAnimation {
                                                    isLoading = false
                                                }
                                            }

                                            
                                        case .failure(let error):
                                            print("Error: \(error.localizedDescription)")
                                        }
                                    }
                                    
                                    
                                case .failure(let error):
                                    print("Failed to fetch files: \(error.localizedDescription)")
                                    // Handle the error, like showing an alert to the user
                                    
                                }
                                
                                
                                
                            }
                            
                        } else {
                            print("Failed to fetch Author user data.")
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
                }
            }
            
        }
        
        
#endif
    }
    
    
    struct PopOverAuthorView: View {
        @EnvironmentObject var appModel: AppModel
        @State private var isHoveringChat = false
        @State private var isHoveringReport = false
        @State private var isHoveringFollow = false
        @State private var isHoveringDelete = false
        @State private var showAlert = false
        @State private var showReportSheet = false
        @State private var showChatSheet = false
        @State private var reportReason = ""
        @State private var messageText = ""
        @State var downloadError = ""
        @Binding var isPresented: Bool
        @Environment(\.presentationMode) var presentationMode
        @Binding var followActive : Bool
        
        var body: some View {
#if os(macOS)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                VStack(alignment: .center, spacing: 0) {
                    
                    if(!followActive)
                    {
                        // Follow Button
                        HStack(alignment: .bottom, spacing: 2) {
                            Image(systemName: "plus.circle")
                            Text("Follow")
                                .font(.system(size: 12, weight: .light))
                        }
                        .foregroundStyle(.blue)
                        .padding(8)
                        .scaleEffect(isHoveringFollow ? 1.1 : 1.0)
                        .onHover { hovering in
                            isHoveringFollow = hovering
                        }
                        .onTapGesture {
                            appModel.toggleFollowStatus {  _ in
                                presentationMode.wrappedValue.dismiss()
                                followActive.toggle()
                                appModel.fetchFollowersAndFollowingFromFollowCollection() { result in
                                    switch result {
                                    case .success(let data):
                                        print("Getting all Followers")
                                        appModel.followers = data.followers
                                        appModel.following = data.following
                                    case .failure(let error):
                                        print("Error fetching followers and following:", error.localizedDescription)
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        // UnFollow Button
                        HStack(alignment: .bottom, spacing: 2) {
                            Image(systemName: "minus.circle")
                            Text("Unfollow")
                                .font(.system(size: 12, weight: .light))
                        }
                        .foregroundStyle(.blue)
                        .padding(8)
                        .scaleEffect(isHoveringFollow ? 1.1 : 1.0)
                        .onHover { hovering in
                            isHoveringFollow = hovering
                        }
                        .onTapGesture {
                            appModel.toggleFollowStatus { _ in
                                presentationMode.wrappedValue.dismiss()
                                followActive.toggle()
                            }
                            appModel.fetchFollowersAndFollowingFromFollowCollection() { result in
                                switch result {
                                case .success(let data):
                                    print("Getting all Followers")
                                    appModel.followers = data.followers
                                    appModel.following = data.following
                                case .failure(let error):
                                    print("Error fetching followers and following:", error.localizedDescription)
                                }
                            }
                        }
                    }
                    
                    // Chat
                    HStack(alignment: .bottom, spacing: 2) {
                        Image(systemName: "message")
                        Text("Message")
                            .font(.system(size: 12, weight: .light))
                    }
                    .foregroundStyle(.blue)
                    .padding(8)
                    .scaleEffect(isHoveringChat ?  1.1 : 1.0)
                    .onHover { hovering in
                        isHoveringChat = hovering
                    }
                    .onTapGesture {
                        showChatSheet = true
                    }.popover(isPresented: $showChatSheet, arrowEdge: .bottom) {
                        
                        VStack{
                            TextField("Type a message", text: $messageText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    appModel.sendMessage(
                                        messageText: messageText,
                                        recipientID: appModel.authorUser.id)
                                    { error in
                                        if let error = error {
                                            print("Error starting conversation: \(error.localizedDescription)")
                                        } else {
//                                            print("Conversation started successfully!")
                                        }
                                    }
                                    isPresented = false
                                    showChatSheet = false
                                }
                            Button("Send") {
                                appModel.sendMessage(
                                    messageText: messageText,
                                    recipientID: appModel.authorUser.id)
                                { error in
                                    if let error = error {
                                        print("Error starting conversation: \(error.localizedDescription)")
                                    } else {
                                        print("Conversation started successfully!")
                                    }
                                }
                                isPresented = false
                                showChatSheet = false
                            }
                            .disabled(messageText.isEmpty)
                            .padding(.top,4)
                        }.padding()
                        
                    }
                    
                    
                    
                    
                    // Report
                    
                    HStack(alignment: .bottom, spacing: 2) {
                        Image(systemName: "flag")
                        Text("Report")
                            .font(.system(size: 12, weight: .light))
                    }
                    .foregroundStyle(.red)
                    .padding(8)
                    .scaleEffect(isHoveringReport ?  1.1 : 1.0)
                    .onHover { hovering in
                        isHoveringReport = hovering
                    }
                    .onTapGesture {
                        showReportSheet = true
                    }.popover(isPresented: $showReportSheet, arrowEdge: .bottom) {
                        
                        VStack{
                            TextField("Reason for reporting", text: $reportReason)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    appModel.addUserReport(for: appModel.authorUser, reason: reportReason) { _ in
                                    }
                                    isPresented = false
                                    showReportSheet = false
                                }
                            Button("Report") {
                                appModel.addUserReport(for: appModel.authorUser, reason: reportReason) { _ in
                                    
                                }
                                isPresented = false
                                showReportSheet = false
                            }
                            .disabled(reportReason.isEmpty)
                            .padding()
                            
                        }.padding()
                        
                    }
                    
                    // Block
//                    
//                    HStack(alignment: .bottom, spacing: 2) {
//                        Image(systemName: "xmark.circle")
//                        Text("Block")
//                            .font(.system(size: 12, weight: .light))
//                    }
//                    .foregroundStyle(.red)
//                    .padding(8)
//                    .scaleEffect(isHoveringReport ?  1.1 : 1.0)
//                    .onHover { hovering in
//                        isHoveringReport = hovering
//                    }
//                    .onTapGesture {
//                        showReportSheet = true
//                    }.popover(isPresented: $showReportSheet, arrowEdge: .bottom) {
//                        
//                        VStack{
//                            TextField("Reason for reporting", text: $reportReason)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .onSubmit {
//                                    appModel.addUserReport(for: appModel.authorUser, reason: reportReason) { _ in
//                                    }
//                                    isPresented = false
//                                    showReportSheet = false
//                                }
//                            Button("Report") {
//                                appModel.addUserReport(for: appModel.authorUser, reason: reportReason) { _ in
//                                    
//                                }
//                                isPresented = false
//                                showReportSheet = false
//                            }
//                            .disabled(reportReason.isEmpty)
//                            .padding()
//                            
//                        }.padding()
//                        
//                    }
//                    
//                    
                
                    
                }}
#elseif os(iOS)
            VStack(alignment: .leading, spacing: 0) {
                      // Follow/Unfollow Button Section
                      Group {
                          if !followActive {
                              HStack(spacing: 8) {
                                  Image(systemName: "plus.circle")
                                  Text("Follow")
                                      .font(.system(size: 16, weight: .regular))
                              }
                              .frame(minHeight: 40)
                              .foregroundStyle(.blue)
                              .padding(.vertical, 10)
                              .frame(maxWidth: .infinity, alignment: .leading)
                              .background(isHoveringFollow ? Color.gray.opacity(0.2) : Color.clear)
                              .onHover { hovering in
                                  isHoveringFollow = hovering
                              }
                              .onTapGesture {
                                  appModel.toggleFollowStatus {  _ in
                                      presentationMode.wrappedValue.dismiss()
                                      followActive.toggle()
                                      appModel.fetchFollowersAndFollowingFromFollowCollection() { result in
                                          switch result {
                                          case .success(let data):
                                              print("Getting all Followers")
                                              appModel.followers = data.followers
                                              appModel.following = data.following
                                          case .failure(let error):
                                              print("Error fetching followers and following:", error.localizedDescription)
                                          }
                                      }
                                  }
                              }
                              
                          } else {
                              HStack(spacing: 8) {
                                  Image(systemName: "minus.circle")
                                  Text("Unfollow")
                                      .font(.system(size: 16, weight: .regular))
                              }
                              .frame(minHeight: 40)
                              .foregroundStyle(.blue)
                              .padding(.vertical, 10)
                              .frame(maxWidth: .infinity, alignment: .leading)
                              .background(isHoveringFollow ? Color.gray.opacity(0.2) : Color.clear)
                              .onHover { hovering in
                                  isHoveringFollow = hovering
                              }
                              .onTapGesture {
                                  appModel.toggleFollowStatus { _ in
                                      presentationMode.wrappedValue.dismiss()
                                      followActive.toggle()
                                  }
                                  appModel.fetchFollowersAndFollowingFromFollowCollection() { result in
                                      switch result {
                                      case .success(let data):
                                          print("Getting all Followers")
                                          appModel.followers = data.followers
                                          appModel.following = data.following
                                      case .failure(let error):
                                          print("Error fetching followers and following:", error.localizedDescription)
                                      }
                                  }
                              }
                              
                          }
                      }
                      .padding(.horizontal)
                Divider() // Divider between items
                // Report Button Section
                HStack(spacing: 8) {
                    Image(systemName: "message")
                    Text("Message")
                        .font(.system(size: 16, weight: .regular))
                }
                .frame(minHeight: 40)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.blue)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(isHoveringChat ? Color.gray.opacity(0.2) : Color.clear)
                .onHover { hovering in
                    isHoveringChat = hovering
                }
                .onTapGesture {
                    showChatSheet = true
                }
                .sheet(isPresented: $showChatSheet) {
                    VStack(spacing: 16) {
                        TextField("Type a message", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        Button("Send") {
                            appModel.sendMessage(
                                messageText: messageText,
                                recipientID: appModel.authorUser.id)
                            { error in
                                if let error = error {
                                    print("Error starting conversation: \(error.localizedDescription)")
                                } else {
                                    print("Conversation started successfully!")
                                }
                            }
                            isPresented = false
                            showChatSheet = false
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding()
                    .presentationDetents([.height(120)])
                    .presentationDragIndicator(.hidden) // Adds a drag indicator to allow user to swipe down to dismiss
                }
                
                
                      Divider() // Divider between items
                      // Report Button Section
                      HStack(spacing: 8) {
                          Image(systemName: "flag")
                          Text("Report")
                              .font(.system(size: 16, weight: .regular))
                      }
                      .frame(minHeight: 40)
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .foregroundStyle(.red)
                      .padding(.vertical, 10)
                      .padding(.horizontal)
                      .background(isHoveringReport ? Color.gray.opacity(0.2) : Color.clear)
                      .onHover { hovering in
                          isHoveringReport = hovering
                      }
                      .onTapGesture {
                          showReportSheet = true
                      }
                      .sheet(isPresented: $showReportSheet) {
                          VStack(spacing: 16) {
                              TextField("Reason for reporting", text: $reportReason)
                                  .textFieldStyle(RoundedBorderTextFieldStyle())
                                  .padding(.horizontal)
                              Button("Report") {
                                  appModel.addUserReport(for: appModel.authorUser, reason: reportReason) { _ in
                                      
                                  }
                                  isPresented = false
                                  showReportSheet = false
                              }
                              .disabled(reportReason.isEmpty)
                          }
                          .padding()
                          .presentationDetents([.height(120)])
                          .presentationDragIndicator(.hidden) // Adds a drag indicator to allow user to swipe down to dismiss
                      }
                  }
            
                  .background(Color.white)
                  .cornerRadius(8)
                  .shadow(radius: 10)
            
#endif

            }
            }
        }
        
        

        

    
    


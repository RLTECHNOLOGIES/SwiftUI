//
//  FollowersView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/12/24.
//

import SwiftUI

struct FollowersView: View {
    @EnvironmentObject var appModel : AppModel
    @State private var showImagePicker = false
    @State private var showCropView = false
    @State private var selectedTab = 0 // Track selected tab
    @State var isLoading: Bool = true
    @Binding var isPresented: Bool
    @State var isAuthorPresented: Bool = false
    @State var userID: String = ""
    var body: some View {
#if os(macOS)
        Group
        {
            if(isAuthorPresented)
            {
                AuthorView(userID: userID,isPresented: $isAuthorPresented)
                    .frame(width: 800,height: 800)
                    
            }
            
        }.opacity(isAuthorPresented ? 1 : 0)
    
    
            
        if(!isAuthorPresented)
        {
                    VStack {
                        VStack(spacing: 0){
                            if(!isAuthorPresented && !isLoading){
                                // Header with back button and sign out
                                HStack {
                                    HStack{
                                        Button {
                                            withAnimation(.snappy(duration: 0.5)) {
                                                isPresented = false
                                            }
                                        } label: {
                                            Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                                            
                                        }
                                        .buttonStyle(.plain)
                                        .padding()
                                        .background(Color.white)
                                    }.onTapGesture {
                                        withAnimation(.snappy(duration: 0.5)) {
                                            isPresented = false
                                        }
                                    }
                                    Spacer()
                                    Text("Social")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.blue)
                                        .padding(.vertical)
                                    Spacer()
                                    Button {
                                        withAnimation(.snappy(duration: 0.5)) {
                                            isPresented = false
                                        }
                                    } label: {
                                        Image(systemName: "chevron.left").foregroundStyle(Color.blue)

                                    }.buttonStyle(.plain)
                                    .padding()
                                    .opacity(0)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.gray.opacity(0.02))
                                )
                                // Custom Tab View
                                
                                HStack(spacing: 0) {
                                    TabButton(title: "Following", isSelected: selectedTab == 0) {
                                        withAnimation { selectedTab = 0 }
                                    }
                                    TabButton(title: "Followed By", isSelected: selectedTab == 1) {
                                        withAnimation { selectedTab = 1 }
                                    }
                                }
                                
                                
                            }
                        }.opacity(isLoading ? 0 : 1)
                        if(isLoading)
                        {
                            ProgressView().scaleEffect(isLoading ? 1 : 0)
                        }
                        VStack(spacing: 0) {
                            
                            if(!isAuthorPresented && !isLoading){
                                
                                // Tab Content
                                if selectedTab == 0
                                {
                                    FollowingTabView(following: appModel.following, userID: $userID, isAuthorPresented: $isAuthorPresented)
                                }
                                if selectedTab == 1
                                {
                                    FollowersTabView(followers: appModel.followers, userID: $userID, isAuthorPresented: $isAuthorPresented)
                                }
                                
                                
                            }
                        }.opacity(isLoading ? 0 : 1)
                            .frame(width: 400)
                            .padding(.vertical, 20)
                        
                    }
                    .onAppear(){
                        // Fetching details for the subviews
                        appModel.fetchFollowersAndFollowingFromFollowCollection() { result in
                            switch result {
                            case .success(let data):
                                print("Getting all Followers")
                                appModel.following = data.following
                                appModel.followers = data.followers
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    withAnimation(.smooth(duration: 0.5)) {
                                        isLoading = false
                                    }
                                }
                            case .failure(let error):
                                print("Error fetching followers and following:", error.localizedDescription)
                            }
                        }
                    }
                    .frame(width: 450, height: 500, alignment: .center)
        }
      
        
#elseif os(iOS)
        ZStack{
            Group
            {
                if(isAuthorPresented)
                {
                    AuthorView(userID: userID,isPresented: $isAuthorPresented)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
                
            }.opacity(isAuthorPresented ? 1 : 0)
            
            VStack {
                VStack(spacing: 0){
                    if(!isAuthorPresented && !isLoading){
                        // Header with back button and sign out
                        HStack {
                            Button {
                                withAnimation(.snappy(duration: 0.5)) {
                                    isPresented = false
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                            }
                            .padding()
                            Spacer()
                            Text("Social")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.blue)
                                .padding(.vertical)
                            Spacer()
                            Button {
                            } label: {
                                Image(systemName: "chevron.left").background(Color.clear)
                            }.opacity(0)
                            .padding()
                        }
                       
                        // Custom Tab View
                        
                        HStack(spacing: 0) {
                            TabButton(title: "Following", isSelected: selectedTab == 0) {
                                withAnimation { selectedTab = 0 }
                            }
                            TabButton(title: "Followed By", isSelected: selectedTab == 1) {
                                withAnimation { selectedTab = 1 }
                            }
                        }
                        
                        
                    }
                }.opacity(isLoading ? 0 : 1)
                ProgressView().scaleEffect(isLoading ? 1 : 0)
                VStack(spacing: 0) {
                    
                    if(!isAuthorPresented && !isLoading){
                        
                        // Tab Content
                        if selectedTab == 0
                        {
                            FollowingTabView(following: appModel.following, userID: $userID, isAuthorPresented: $isAuthorPresented)
                        }
                        if selectedTab == 1
                        {
                            FollowersTabView(followers: appModel.followers, userID: $userID, isAuthorPresented: $isAuthorPresented)
                        }
                        
                        
                    }
                }
                .opacity(isLoading ? 0 : 1)
                .padding(.vertical, 2)
                
            }
            .onAppear(){
                // Fetching details for the subviews
                appModel.fetchFollowersAndFollowingFromFollowCollection() { result in
                    switch result {
                    case .success(let data):
                        print("Getting all Followers")
                        appModel.following = data.following
                        appModel.followers = data.followers
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation(.smooth(duration: 0.5)) {
                                isLoading = false
                            }
                        }
                    case .failure(let error):
                        print("Error fetching followers and following:", error.localizedDescription)
                    }
                }
            }
            
        }
        
#endif
        
    }
    

    // Custom Tab Button
    struct TabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        
        var body: some View {
            
            VStack{
                Text(title)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .cornerRadius(8)
            }
            
            .background(Color.white)
                .onTapGesture {
                    action()
                }
        }
    }

    struct FollowingTabView: View {
        
        var following : [Follow]
        @Binding var userID : String
        @Binding var isAuthorPresented : Bool
        @State private var isTapEnabled = false
        
        var body: some View {
            #if os(macOS)
            
            VStack(alignment: .center){
                List{
                    
                        ForEach(following) { follower in
                            
                            FollowingRow(follow: follower).onTapGesture {
                                if isTapEnabled {
                                    userID = follower.userIDFollowing
                                        isAuthorPresented = true
                                }
                            }
                        }.listRowSeparator(.hidden)
                    
                }
              
            }
            .padding(.leading, 5)
            .onAppear {
                // Enable tap gesture after 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isTapEnabled = true
                }
            }
            #elseif os(iOS)
            
            VStack(alignment: .center){
                List{
                    ForEach(following) { follower in
                        FollowingRow(follow: follower).onTapGesture {
                            if isTapEnabled {
                                userID = follower.userIDFollowing
                                withAnimation {
                                    isAuthorPresented = true
                                }
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .frame(maxWidth: 400)
                .padding(.horizontal,5)
                .listStyle(.plain)
                .onAppear {
                    // Enable tap gesture after 1 second
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isTapEnabled = true
                    }
                }
                
            }
            
            
            
            
            #endif
        }
    }
    struct FollowingRow: View {
        let follow: Follow
        @State var isHovering: Bool = false
        
        var body: some View {
                ZStack{
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 2)
                    
                    HStack{
                        // Profile picture, using a placeholder if the profilePicture URL is empty
                        
#if os(macOS)
                        HStack{
                            AsyncImageView(
                                                    urlString: follow.profilePictureFollowing,
                                                    placeholder: Image("icon")
                                                )
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            Text(follow.userNameFollowing)
                                .font(.system(size: 14)) //
                                .foregroundColor(.blue)
                                .padding(.horizontal, 2)
                                .padding(.top, 4)
                        }.padding()
#elseif os(iOS)
                            HStack{
                            AsyncImageView(
                                                    urlString: follow.profilePictureFollowing,
                                                    placeholder: Image("icon")
                                                )
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.gray, lineWidth: 1)).padding(.leading)
                            Text(follow.userNameFollowing)
                                .font(.system(size: 18)) //
                                .foregroundColor(.blue)
                                .padding(.leading)
                                .padding(.top, 4)
                            }
                            
#endif
                           
                        
                        Spacer()
                        
                    }

                    
                }
//#if os(iOS)
//                    .frame(maxWidth: 400)
//#endif
                
                .scaleEffect(isHovering ? 1.0 : 0.9)
                .onHover { hovering in
                    withAnimation {
                        isHovering = hovering
                    }
                }
            }
    }
    
    
    
    
    // Settings Tab Content
    struct FollowersTabView: View {
        var followers: [Follow]
        @Binding var userID: String
        @Binding var isAuthorPresented: Bool
        @State private var isTapEnabled = false  // Track if tap gesture is enabled

        var body: some View {
            
                
                    #if os(macOS)
                    
                    VStack(alignment: .center){
                        List{
                            
                                ForEach(followers) { follower in
                                    
                                    FollowersRow(follow: follower).onTapGesture {
                                        if isTapEnabled {
                                            userID = follower.userIDFollowedBy
                                                isAuthorPresented = true
                                        }
                                    }
                                }.listRowSeparator(.hidden)
                            
                        }
                      
                    }
                    .padding(.leading, 5)
                    .onAppear {
                        // Enable tap gesture after 1 second
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isTapEnabled = true
                        }
                    }
                    #elseif os(iOS)
                    
                    
                        List{
                                ForEach(followers) { follower in
                                    
                                    FollowersRow(follow: follower).onTapGesture {
                                        if isTapEnabled {
                                            userID = follower.userIDFollowedBy
                                            withAnimation {
                                                isAuthorPresented = true
                                            }
                                        }
                                    }
                                }
                                
                                .listRowSeparator(.hidden)
                        }
                        .frame(maxWidth: 400)
                        .padding(.horizontal,5)
                        .listStyle(.plain)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isTapEnabled = true
                            }
                        }
                      
                    
                    
                    
                    
                    
                    #endif
                
            
        }
    }
    
    struct FollowersRow: View {
        let follow: Follow
        @State var isHovering: Bool = false
        
        var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 2)
                
                HStack{
                    // Profile picture, using a placeholder if the profilePicture URL is empty
             
#if os(macOS)
                        HStack{
                            AsyncImageView(
                                urlString: follow.profilePictureFollowedBy,
                                placeholder: Image("icon")
                            )
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            Text(follow.userNameFollowedBy)
                                .font(.system(size: 14)) //
                                .foregroundColor(.blue)
                                .padding(.horizontal, 2)
                                .padding(.top, 4)
                        }.padding()
#elseif os(iOS)
                    HStack{
                        AsyncImageView(
                                                urlString: follow.profilePictureFollowedBy,
                                                placeholder: Image("icon")
                                            )
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 1)).padding(.leading)
                        Text(follow.userNameFollowedBy)
                            .font(.system(size: 18)) //
                            .foregroundColor(.blue)
                            .padding(.leading)
                            .padding(.top, 4)
                    }
#endif
                       
                    
                    Spacer()
                    
                }
                
            }
            
            .scaleEffect(isHovering ? 1.0 : 0.9)
            .onHover { hovering in
                withAnimation {
                    isHovering = hovering
                }
            }
        }
    }

}

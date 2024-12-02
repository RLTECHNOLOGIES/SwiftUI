//
//  UserProfileView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/11/24.
//
import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var iconTapped: Int? = nil
    @State var isFollowersPresented = false
    @State var isUploadsPresented = false
    @State var expand: Bool = false
    @State var isSettingsPresented = false
    @State var isfavoritesPresented = false
    @State var isHoveringPic: Bool = false
    
    
    
    func handleIconTap(at index: Int) {
        switch icons[index].1 {
        case "Social":
            withAnimation(.snappy(duration: 0.5)) {
                isFollowersPresented = true
                appModel.isFollowersPresented = true
                
            }
        case "Uploads":
            withAnimation(.snappy(duration: 0.5)) {
                isUploadsPresented = true
                appModel.isUploadsPresented = true
            }
        case "Favourites":
            withAnimation(.snappy(duration: 0.5)) {
                isfavoritesPresented = true
                appModel.isfavoritesPresented = true
            }
        case "Settings":
            withAnimation(.snappy(duration: 0.5)) {
                isSettingsPresented = true
                appModel.isSettingsPresented = true
            }
        default:
            break
        }
    }
    // Icons and their corresponding names
    let icons = [
        ("person.circle", "Social"),
        ("star", "Favourites"),
        ("gear.circle", "Settings"),
        ("arrow.up.circle", "Uploads")
    ]
#if os(macOS)
    let iconRadius: CGFloat = 140
#elseif os(iOS)
    let iconRadius: CGFloat = 120
#endif
    
    var body: some View {

        #if os(macOS)
        ZStack {
                ZStack {
                    ProfileImageView(isSettingsPresented: $isSettingsPresented, isHovered: $expand)
                    IconsView(
                        icons: icons,
                        iconRadius: iconRadius,
                        expand: $expand,
                        iconTapped: $iconTapped,
                        handleIconTap: handleIconTap
                    )
                    if appModel.isUploadsPresented {
                                 UploadsView(isPresented: $appModel.isUploadsPresented)
                                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                                     .background(Color.white)
                                     .transition(.opacity)
                                     .zIndex(1)
                             }
                }
                
                .padding(.bottom,50)

                .frame(width: 500, height: 500)
            
            if appModel.isUploadsPresented {
                         UploadsView(isPresented: $appModel.isUploadsPresented)
                             .frame(maxWidth: .infinity, maxHeight: .infinity)
                             .background(Color.white)
                             .transition(.opacity)
                             .zIndex(1)
                     }
            if appModel.isfavoritesPresented {
                           FavoritesView(isPresented: $appModel.isfavoritesPresented)
                               .frame(maxWidth: .infinity, maxHeight: .infinity)
                               .background(Color.white)
                               .transition(.opacity)
                               .zIndex(1)
                       }
        }
        
        
        .onHover { isHovering in
            isHoveringPic = isHovering
            withAnimation(.bouncy(duration: 0.5)) {
                expand = isHovering
            }
        }
        .onAppear {
            withAnimation(.bouncy(duration: 0.5)) {
                expand = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if(!isHoveringPic){
                        withAnimation(.easeInOut(duration: 0.5)) {
                            expand = false
                        }
                    }
                }
            }
            isFollowersPresented = false
            isUploadsPresented = false
            isSettingsPresented = false
            isfavoritesPresented = false
            
            appModel.getAllUploadedFiles()
            appModel.getAllfavoritedFiles {
//                print("Getting all favorited files")
            }
            
        }   .sheet(isPresented: $appModel.isSettingsPresented, content: { SettingsView(isPresented: $appModel.isSettingsPresented) })
            .sheet(isPresented: $appModel.isFollowersPresented, content: { FollowersView(isPresented: $appModel.isFollowersPresented) })
//            .sheet(isPresented: $appModel.isUploadsPresented, content: { UploadsView(isPresented: $appModel.isUploadsPresented)})
//            .sheet(isPresented: $appModel.isfavoritesPresented, content: { FavoritesView(isPresented: $appModel.isfavoritesPresented) })
           
#elseif os(iOS)
        
        
            
        VStack {
            ZStack {
                Group{
                    ProfileImageView(isSettingsPresented: $isSettingsPresented, isHovered: $expand)
                    IconsView(
                        icons: icons,
                        iconRadius: iconRadius,
                        expand: $expand,
                        iconTapped: $iconTapped,
                        handleIconTap: handleIconTap
                    )
                    }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .drawingGroup()
                    }
                    .padding(.bottom,50)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .onTapGesture {
                    withAnimation(.bouncy(duration: 0.5)) {
                        expand.toggle()
                    }
                }
                .onAppear {
            expand = false
            appModel.getAllUploadedFiles()
            appModel.getAllfavoritedFiles {
//                print("Getting all favorited files")
            }
                }
                .sheet(isPresented: $appModel.isSettingsPresented, content: { SettingsView(isPresented: $appModel.isSettingsPresented) })
                .fullScreenCover(isPresented: $appModel.isFollowersPresented, content: { FollowersView(isPresented: $appModel.isFollowersPresented) })
                .fullScreenCover(isPresented: $appModel.isUploadsPresented, content: { UploadsView(isPresented: $appModel.isUploadsPresented) })
                .fullScreenCover(isPresented: $appModel.isfavoritesPresented, content: { FavoritesView(isPresented: $appModel.isfavoritesPresented) })
                .onChange(of: appModel.isSettingsPresented || appModel.isFollowersPresented || appModel.isUploadsPresented || appModel.isfavoritesPresented) { oldValue, newValue in
                    if newValue == false {
//                        withAnimation(.easeIn(duration: 0.5)) {
//                            expand = false
//                        }
                    }
                }
        #endif
        
    }
    
    
}

struct ContentSwitcherView: View {
    @Binding var isFollowersPresented: Bool
    @Binding var isUploadsPresented: Bool
    @Binding var isSettingsPresented: Bool
    @Binding var isfavoritesPresented: Bool
    
    var body: some View {
        ZStack {
            if isSettingsPresented {
                SettingsView(isPresented: $isSettingsPresented)
                    .transition(.scale)
                    .zIndex(1)
            }
            if isfavoritesPresented {
                FavoritesView(isPresented: $isfavoritesPresented)
                    .transition(.opacity)
                    .zIndex(1)
            }
            if isUploadsPresented {
                UploadsView(isPresented: $isUploadsPresented)
                    .transition(.opacity)
                    .zIndex(1)
            }
            if isFollowersPresented {
                FollowersView(isPresented: $isFollowersPresented)
                    .transition(.scale)
                    .zIndex(1)
            }
        }
    }
}
struct IconsView: View {
    let icons: [(String, String)]
    let iconRadius: CGFloat
    @Binding var expand: Bool
    @Binding var iconTapped: Int?
    var handleIconTap: (Int) -> Void
    
    // Calculate icon positions
    func iconPosition(for index: Int, totalIcons: Int, radius: CGFloat) -> CGPoint {
        let angle = (2.0 * Double.pi * Double(index) / Double(totalIcons)) - (Double.pi / 2)
        return CGPoint(
            x: radius * CGFloat(Foundation.cos(angle)),
            y: radius * CGFloat(Foundation.sin(angle))
        )
    }
    
    
    var body: some View {
#if os(macOS)
        ZStack {
            if expand {
                ForEach(0..<icons.count, id: \.self) { index in
                    let position = iconPosition(for: index, totalIcons: icons.count, radius: iconRadius)
                    VStack {
                        Image(systemName: icons[index].0)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(8)
                            .foregroundStyle(.gray)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .shadow(radius: 2)
//                            .scaleEffect(iconTapped == index ? 0.9 : 1.0)
//                            .opacity(iconTapped == index ? 0.8 : 1.0)
//                            .animation(.easeInOut.speed(2), value: iconTapped)
                        Text(icons[index].1)
                            .foregroundColor(.gray)
                    }
                    .offset(x: position.x, y: position.y)
                    .transition(.scale)
                    .onTapGesture {
                        withAnimation {
                            iconTapped = index
                        }
                        handleIconTap(index)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            iconTapped = nil
                        }
                    }
                }
            }
        }
#elseif os(iOS)
        ZStack {
            
                ForEach(0..<icons.count, id: \.self) { index in
                    let position = iconPosition(for: index, totalIcons: icons.count, radius: iconRadius)
                    VStack {
                        Image(systemName: icons[index].0)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(5)
                            .foregroundStyle(.gray)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .shadow(radius: 2)
                        Text(icons[index].1)
                            .foregroundColor(.gray)
                    }
                    .offset(x: position.x, y: position.y)
//                    .transition(.scale)
                    .scaleEffect(expand ? 1 : 0.01)
//                    .opacity(expand ? 1 : 0)
                    .onTapGesture {
                        withAnimation {
                            iconTapped = index
                        }
                        handleIconTap(index)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            iconTapped = nil
                        }
                    }
                     
                }
            
        }
#endif
        
    }
}
struct ProfileImageView: View {
    @EnvironmentObject var appModel: AppModel
    @Binding var isSettingsPresented: Bool
    @Binding var isHovered: Bool
    
    
    var body: some View {
        
#if os(macOS)
        VStack {
            
            AsyncImageView(urlString: appModel.user.profilePicture,
                           placeholder: Image("icon"))
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .shadow(radius: 5)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isSettingsPresented = true
                        }
                    }
                if(!isHovered){
                    Text(appModel.username)
                        .font(.title)
                        .padding(.top, 5)
                        .foregroundStyle(Color.gray)
                }
            
        }
#elseif os(iOS)
        VStack {
            
            AsyncImageView(urlString: appModel.user.profilePicture,
                           placeholder: Image("icon"))
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .onAppear {
                        print(appModel.user.profilePicture)
                    }
            
                if(!isHovered){
                    Text(appModel.username)
                        .font(.title)
                        .padding(2)
                        .foregroundStyle(Color.gray)
                }
            
        }
#endif
        
    }
}

//
//  HomeView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/11/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var isHovering: [Int: Bool] = [:] // Track hover state for each tab
    
    
    private let tabs = [
        TabItem(title: "Trending", icon: "chart.line.uptrend.xyaxis", tag: 0),
        TabItem(title: "Search", icon: "magnifyingglass", tag: 1),
        TabItem(title: "Upload", icon: "square.and.arrow.up", tag: 2),
        TabItem(title: "Inbox", icon: "tray", tag: 3),
        TabItem(title: "Profile", icon: "person.crop.circle", tag: 4)
    ]
    
    var body: some View {
        Group {
            
#if os(macOS)
            if (!appModel.user.isActive)
            {
                DisabledAccountView().environmentObject(appModel)
               
            }
            else{
                HStack(spacing: 0) {
                    customTabs // Side tab bar
                        .background(Color.gray.opacity(0.1))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: 0)
                    
                    Divider()
                    contentView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
#elseif os(iOS)
            
            if (!appModel.user.isActive)
            {
                DisabledAccountView().environmentObject(appModel)
            }
            else{
                TabView(selection: $appModel.selectedTab) {
                    ForEach(tabs, id: \.tag) { tab in
                        contentView
                            .tabItem {
                                Label(tab.title, systemImage: tab.icon)
                            }
                            .tag(tab.tag)
                    }
                }
            }
#endif
                
            
        }
        .environmentObject(appModel)
    }
    
    // Content View based on selection
    private var contentView: some View {
        Group {
            switch appModel.selectedTab {
            case 0:
                AnyView(ExploreView())
            case 1:
                AnyView(SearchView())
            case 2:
                AnyView(UploadView())
            case 3:
                AnyView(MessagingView())
            case 4:
                AnyView(UserProfileView())
            default:
                AnyView(SearchView())
            }
        }
        .onAppear {
#if os(macOS)
                appModel.selectedTab = 0
#endif
        }
    }
    
    // Custom Tabs View
    private var customTabs: some View {
        Group {
            if appModel.orientation == .landscape {
                    VStack(spacing: 1) { // Vertical tabs for landscape
                        Spacer()
                        ForEach(tabs.dropLast(), id: \.tag) { tab in
                            tabView(for: tab)
                        }
                        Spacer() // Push the last tab to the bottom
                        
                        // Last tab at the bottom
                        if let lastTab = tabs.last {
                            tabView(for: lastTab)
                        }
                    }
            }
        }
    }
    
    private func tabView(for tab: TabItem) -> some View {
        
#if os(macOS)
        VStack {
            VStack(spacing: 0) {
                Image(systemName: tab.icon)
                    .foregroundStyle(Color.gray.opacity(1))
                Text(tab.title)
                    .foregroundStyle(Color.gray.opacity(1))
            }
            .scaleEffect(appModel.selectedTab == tab.tag ? 1.0 : 0.9)
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        appModel.selectedTab == tab.tag ? Color.gray.opacity(0.2) : (isHovering[tab.tag] == true ? Color.gray.opacity(0.1) : Color.white)
                    )
            )
            .onHover { hovering in
                isHovering[tab.tag] = hovering // Update hover state
            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    appModel.selectedTab = tab.tag
                }
            }
        }.padding(5)
#elseif os(iOS)
        VStack{}
#endif
        
    }
}

// Tab Item Model
struct TabItem {
    let title: String
    let icon: String
    let tag: Int
}


struct DisabledAccountView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        VStack {
            Text("Your account was disabled")
                .font(.title)
            
            HStack {
                Button {
                    appModel.activateUser { result in
                        if case .success = result {
                            appModel.user.isActive = true
                        }
                    }
                } label: {
                    Text("Enable Account")
                }
                .buttonStyle(CapsuleButtonStyle(labelColor: .white, backgroundColor: .blue, padding: 10))
                .padding()
                
                Button(action: {
                    appModel.signOut { result in
                        switch result {
                        case .success:
                            print("Sign-out successful")
                            // Navigate to login screen or perform other UI updates
                        case .failure(let error):
                            print("Sign-out failed: \(error.localizedDescription)")
                            // Show an error message to the user
                        }
                    }
                }) {
                    Text("Sign Out")
                }
                .buttonStyle(CapsuleButtonStyle(labelColor: .white, backgroundColor: .red, padding: 10))
                .padding()
            }
        }
    }
}

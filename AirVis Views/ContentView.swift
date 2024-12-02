//
//  ContentView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/11/24.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var appModel: AppModel
#if os(iOS)
    @StateObject private var monitor = FPSMonitor()
#endif
    
    
    var body: some View {
        Group {
            if appModel.isInitializing || appModel.isOffline{
                       loadingView
                   } else {
                       switch appModel.currentAppState {
                       case .configuring:
                           Text("Configuring...")
                       case .needsAuthentication:
                           LandingView()
                       case .needsOnboarding:
                           onboardingFlow
                       case .needsTermsAgreement:
                           TermsAndConditionsView()
                       case .ready:
                            #if os(macOS)
                            Divider()
                            #endif

                           HomeView()
                               .onAppear {
                                   
                               if(appModel.conversationChangelistener == nil)
                               {
                                   appModel.fetchLatestConversations(limit: 50, lastDocument: nil) { conversations, lastDoc, error in
                                       if let conversations = conversations {
                                           appModel.conversations = conversations
                                           appModel.lastConversationDocumentSnapshot = lastDoc // Store for the next batch
                                               appModel.listenForNewConversations()
                                               {
                                                   newConversation, error in
                   //                                print("New Conversation: \(newConversation)")
                                               }
                                           
                                       }
                                    
                                   }
                               }
                           }.onDisappear {
                               appModel.stoplistenForConversationChange()
                           }
                       }
                       
                   }
        }
        .environmentObject(appModel)
       
#if os(iOS)
        .fullScreenCover(isPresented: $appModel.fileView, content: {
            DetailedFileView(file: appModel.activeDisplayFile, presented: $appModel.fileView).frame(maxWidth: .infinity, maxHeight: .infinity)
        })
#elseif os(macOS)
        .sheet(isPresented: $appModel.fileView, content: {
            DetailedFileView(file: appModel.activeDisplayFile, presented: $appModel.fileView).frame(maxWidth: .infinity, maxHeight: .infinity)
        })
#endif
        
    }
    
    private var loadingView: some View {
        ProgressView()
    }
    private var onboardingFlow: some View {
        VStack {
            TermsAndConditionsView()
                .sheet(isPresented: $appModel.showProfileSetup) {
                    SettingsView(isPresented: $appModel.showProfileSetup)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
        }
        .navigationTitle("Terms & Conditions")
    }

}



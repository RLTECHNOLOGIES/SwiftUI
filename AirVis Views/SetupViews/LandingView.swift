//
//  LandingVirw.swift
//  AirVis
//
//  Created by Arun Kurian on 11/7/24.
//

import SwiftUI

struct LandingView: View {
    @EnvironmentObject var appModel: AppModel
    var body: some View {
#if os(macOS)
        
        ZStack(){
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500)
                .padding(.bottom,180)
            VStack
            {
                AppleAuthenticationView().environmentObject(appModel)
                EmailSignInButton().environmentObject(appModel)
                
            }.padding(.top,130)
        }
#elseif os(iOS)
        ZStack(){
            Image("logo")
                .resizable()
                .scaledToFit()
                .padding(.bottom,180)
                .padding(.leading,10)
            VStack
            {
                AppleAuthenticationView().environmentObject(appModel)
                EmailSignInButton().environmentObject(appModel)
                
            }.padding(.top,170)
        }
        
#endif
    }
}

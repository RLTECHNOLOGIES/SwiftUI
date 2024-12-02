//
//  TermsAndConditionView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/11/24.
//

import SwiftUI

struct TermsAndConditionsView: View {
    @EnvironmentObject var appModel: AppModel
    @State var tempAgreedToTerms: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
#if os(macOS)
        ZStack {
            
            VStack(spacing: 20) {

                Text("Terms and Conditions")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 40)

                List {
                    Text(appModel.termsText)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
                Toggle(isOn: $tempAgreedToTerms) {
                    Text("I agree to the Terms and Conditions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                // Button to navigate to Profile Setup
                HStack{
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
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    Button("Continue") {
                        appModel.agreedToTerms = tempAgreedToTerms
                        if appModel.agreedToTerms {
                            if !appModel.onboardingCompleted{
                                appModel.showProfileSetup = true
                            }
                            else
                            {
                                appModel.updateUserAgreement(agreedToTerms: appModel.agreedToTerms) { _ in
                                    //                                print("Success")
                                }
                            }
                        }
                    }
                    .disabled(!tempAgreedToTerms)
                    .buttonStyle(.borderedProminent)
                  
                }.padding()
                
             
            }
        }.onAppear(perform: appModel.loadTerms)
        
#elseif os(iOS)
        ZStack {
            if(!appModel.termsText.isEmpty)
            {
            VStack(spacing: 20) {
                
                Text("Terms and Conditions")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 40)

                List {
                    Text(appModel.termsText)
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top,2)
                .listStyle(.plain)
                .background(Color.white)
                Toggle(isOn: $tempAgreedToTerms) {
                    Text("I agree to the Terms and Conditions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                
                HStack{
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
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    Spacer()
                    Button("Continue") {
                        appModel.agreedToTerms = tempAgreedToTerms
                        if appModel.agreedToTerms {
                            if !appModel.onboardingCompleted{
                                appModel.showProfileSetup = true
                            }
                            else
                            {
                                appModel.updateUserAgreement(agreedToTerms: appModel.agreedToTerms) { _ in
                                    //                                print("Success")
                                }
                            }
                        }
                    }
                    .disabled(!tempAgreedToTerms)
                    .buttonStyle(.borderedProminent)
                  
                }.padding()
             
            }
            }
            else
            {
                ProgressView()
            }
        }
        .onAppear(perform: appModel.loadTerms)
#endif
    }
}

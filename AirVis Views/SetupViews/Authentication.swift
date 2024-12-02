//
//  Authentication.swift
//  AirVis
//
//  Created by Arun Kurian on 11/11/24.
//

import SwiftUI
import AuthenticationServices

struct AppleAuthenticationView: View {
    @State private var currentNonce: String? // Store the generated nonce
    @EnvironmentObject var appModel: AppModel
    var body: some View {
            
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    appModel.handleSignInWithAppleRequest(request)
                },
                onCompletion: { result in
                    appModel.handleSignInWithAppleCompletion(result)
                }
            )
            .frame(width: 210, height: 40)
        
        
    }
    
}

struct EmailSignInButton: View {
    @EnvironmentObject var appModel: AppModel
    @State private var showSheet = false // State variable to control sheet visibility
    
    var body: some View {
#if os(macOS)
        Button(action: {
            showSheet = true // Show the sheet on button tap
        }) {
            HStack(spacing: 2) {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 10))
                
                Text("Sign in with Email")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 210, height: 28)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showSheet) {
            EmailTabView().environmentObject(appModel)
                
            // Show the email sign-in sheet when button is pressed
        }
#elseif os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
        Button(action: {
            showSheet = true // Show the sheet on button tap
        }) {
            HStack(spacing: 2) {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 13))
                
                Text("Sign in with Email")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 210, height: 38)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showSheet) {
            EmailTabView().environmentObject(appModel).ignoresSafeArea(.keyboard, edges: .bottom)
                .presentationDetents([.height(500)])
                .presentationDragIndicator(.hidden)
                
            // Show the email sign-in sheet when button is pressed
        }
        }
        
        else // IPAD
        {
            Button(action: {
            showSheet = true // Show the sheet on button tap
        }) {
            HStack(spacing: 2)
            {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 13))
                
                Text("Sign in with Email")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 210, height: 38)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showSheet) {
            EmailTabView().environmentObject(appModel).ignoresSafeArea(.keyboard, edges: .bottom)
                .presentationDetents([.height(550)])
                .presentationDragIndicator(.hidden)
                
            // Show the email sign-in sheet when button is pressed
        }
            
        }
#endif
    }
}







struct EmailTabView: View {
    @EnvironmentObject var appModel : AppModel
    @State private var selectedTab = 0 // Track selected tab
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
#if os(macOS)
        
                VStack {
                    
                        VStack(spacing: 0){
                            HStack {
                                Button {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                } label: {
                                    Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                                }
                                .buttonStyle(.plain)
                                
                                Spacer()
                                Text("User Account")
                                    .font(.system(size: 17))
                                    .foregroundStyle(.blue)
                                Spacer()
                                
                                Button {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                } label: {
                                    Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                                }
                                .buttonStyle(.plain)
                                .opacity(0)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.gray.opacity(0.02))
                            )
                            // Custom Tab View
                            Divider()
                            HStack(spacing: 0) {
                                EmailTabButton(title: "Existing Account", isSelected: selectedTab == 0) {
                                    withAnimation { selectedTab = 0 }
                                }
                                EmailTabButton(title: "Create an Account", isSelected: selectedTab == 1) {
                                    withAnimation { selectedTab = 1 }
                                }
                            }
                            Divider()
                            
                        }
                        VStack(spacing: 0) {
                            
                            
                                
                                // Tab Content
                                if selectedTab == 0
                                {
                                    SignInTabView()
                                }
                                if selectedTab == 1
                                {
                                    SignUpTabView()
                                }
                                
                                
                            
                        }
//                        .frame(width: 400)
//                        .padding(.vertical, 60)

                    
                    
                    
                            .padding(.top, 50)
                                    .frame(width: 400, height: 400, alignment: .center)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.5), lineWidth: 0.3)
                )
#elseif os(iOS)
                VStack {
                        VStack(spacing: 0){
                            HStack {
                                Button {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                } label: {
                                    Image(systemName: "chevron.left")
                                }.padding()
                                Spacer()
                                Text("User Account")
                                    .font(.system(size: 19))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.blue)
                                    .padding(.vertical)
                                Spacer()
                                Button {
                                } label: {
                                    Image(systemName: "chevron.left")
                                }.opacity(0).padding()
                            }
                            // Custom Tab View
                            
                            HStack(spacing: 0) {
                                EmailTabButton(title: "Existing Account", isSelected: selectedTab == 0) {
                                    withAnimation { selectedTab = 0 }
                                }
                                EmailTabButton(title: "Create an Account", isSelected: selectedTab == 1) {
                                    withAnimation { selectedTab = 1 }
                                }
                            }
                            
                            
                        }
                        
                        VStack(spacing: 0) {
                                // Tab Content
                                if selectedTab == 0
                                {
                                    SignInTabView()
                                }
                                if selectedTab == 1
                                {
                                    SignUpTabView()
                                }
                        }.padding(.top, 70)
                        Spacer()
                }
                
        
#endif
        
    }
    
    struct SignInTabView: View {
        @EnvironmentObject var appModel: AppModel
        @FocusState private var focusedField: Field?
        private enum Field: Hashable {
               case email, password
           }
           
        var body: some View {
#if os(macOS)
            
            VStack(spacing: 25) {
                
                // Input Fields
                VStack(spacing: 12) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 5) {
                        
                        TextField("Enter your email", text: $appModel.emailID)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 240, height: 40)
                            )
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        
                        
                        SecureField("Enter your password", text: $appModel.emailPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 240, height: 40)
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.done)
                            .onSubmit {
                                appModel.signInWithEmailPassword()
                            }
                    }
                    VStack(spacing: 5)
                    {
                        Button(action: {
                            appModel.signInWithEmailPassword()
                        }) {
                            HStack(spacing: 5) {

                                Text("Sign in with Email")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.right.square")
                                    .foregroundColor(.white)
                                    .font(.system(size: 10))

                            }
                            
                            .frame(width: 200, height: 30)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding()
                        
                        Button {
                            appModel.promptResetPassword()
                        } label: {
                            Text("Forgot Password?")
                        }
                        .buttonStyle(.link)
                    }
                }
                .frame(width: 250)
                
            }
            .padding(.bottom, 150)
            .padding(.top, 50)
            
#elseif os(iOS)
            
            VStack(spacing: 25) {
                
                // Input Fields
                VStack(spacing: 12) {
                    // Email Field
                    VStack(alignment: .leading) {
                        
                        TextField("Enter your email", text: $appModel.emailID)
                            .textFieldStyle(PlainTextFieldStyle())
                            .autocorrectionDisabled(true) // Disables autocorrection
                            .textInputAutocapitalization(.never) // Disables autocapitalization
                            .font(.system(size: 18))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 240, height: 40)
                                    .onTapGesture {
                                        focusedField = .email
                                    }
                            )
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                           
                    }
                    
                    // Password Field
                    VStack(alignment: .leading) {
                        
                        
                        SecureField("Enter your password", text: $appModel.emailPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 18))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 240, height: 40)
                                    .onTapGesture {
                                        focusedField = .password
                                    }
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.done)
                            .onSubmit {
                                appModel.signInWithEmailPassword()
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        focusedField = nil
                                    }
                                }
                            }
                    }
                    VStack(spacing: 5)
                    {
                        Button(action: {
                            appModel.signInWithEmailPassword()
                        }) {
                            HStack(spacing: 5) {
 
                                Text("Sign in with Email")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.right.square")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                            
                            .frame(width: 200, height: 35)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding()
                        
                        Button {
                            appModel.promptResetPassword()
                        } label: {
                            Text("Forgot Password?")
                        }
                    }
                }
                .frame(width: 250)
                
            }
            
            
      
#endif
        }

    }
    
    struct SignUpTabView: View {
        @EnvironmentObject var appModel: AppModel
        @FocusState private var focusedField: Field?
        @State private var reEnterPassword: String = ""
        @State private var password: String = ""
        
        private enum Field: Hashable {
               case email, password, reEnterPassword
           }
           
        var body: some View {
            
#if os(macOS)
            
            VStack(spacing: 25) {
              
//
//                Text("Sign in to your account")
//                    .font(.system(size: 16))
//                    .foregroundColor(.secondary)
                
                // Input Fields
                VStack(spacing: 12) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
       
                        TextField("Enter your email", text: $appModel.emailID)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 240, height: 40)
                            )
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 240, height: 40)
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.done)
                            .onSubmit {
                                focusedField = .reEnterPassword
                            }
                    }
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        
                        
                        SecureField("Re-enter your password", text: $reEnterPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 240, height: 40)
                            )
                            .focused($focusedField, equals: .reEnterPassword)
                            .submitLabel(.done)
                            .onSubmit {
                                if(reEnterPassword == password)
                                {
                                    appModel.signUpWithEmailPassword(email: appModel.emailID, password: reEnterPassword)
                                }
                                else
                                {
                                    appModel.promptPasswordMismatch()
                                }
                            }
                    }
                    
                    
                     Button(action: {
                        if(reEnterPassword == password)
                        {
                            appModel.signUpWithEmailPassword(email: appModel.emailID, password: reEnterPassword)
                        }
                        else
                        {
                            appModel.promptPasswordMismatch()
                        }
                    }) {
                        HStack(spacing: 5) {
                            
                            Text("Sign up with Email")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                            Image(systemName: "chevron.up.square")
                                .foregroundColor(.white)
                                .font(.system(size: 10))
                        }
                        .frame(width: 200, height: 30)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding()
                    }
                    .buttonStyle(PlainButtonStyle())

                }
                .frame(width: 250)
                
            }
            .padding(.bottom, 150)
            .padding(.top, 50)
#elseif os(iOS)
            VStack(spacing: 25) {
                VStack(spacing: 12) {
                    // Email Field
                    VStack(alignment: .leading) {
       
                        TextField("Enter your email", text: $appModel.emailID)
                            .autocorrectionDisabled(true) // Disables autocorrection
                            .textInputAutocapitalization(.never) // Disables autocapitalization
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 240, height: 40)
                                    .onTapGesture {
                                        focusedField = .email
                                    }
                            )
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        focusedField = nil
                                    }
                                }
                            }
                    }
                    
                    // Password Field
                    VStack(alignment: .leading) {
                        
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 240, height: 40)
                                    .onTapGesture {
                                        focusedField = .password
                                    }
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.done)
                            .onSubmit {
                                focusedField = .reEnterPassword
                            }
                    }
                    // Password Field
                    VStack(alignment: .leading) {
                        
                        
                        SecureField("Re-enter your password", text: $reEnterPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 240, height: 40)
                                    .onTapGesture {
                                        focusedField = .reEnterPassword
                                    }
                            )
                            .focused($focusedField, equals: .reEnterPassword)
                            .submitLabel(.done)
                            .onSubmit {
                                if(reEnterPassword == password)
                                {
                                    appModel.signUpWithEmailPassword(email: appModel.emailID, password: reEnterPassword)
                                }
                                else
                                {
                                    appModel.promptPasswordMismatch()
                                }
                            }
                    }
                    
                    
                     Button(action: {
                        if(reEnterPassword == password)
                        {
                            appModel.signUpWithEmailPassword(email: appModel.emailID, password: reEnterPassword)
                        }
                        else
                        {
                            appModel.promptPasswordMismatch()
                        }
                    }) {
                        HStack(spacing: 5) {
                            
                            Text("Sign up with Email")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Image(systemName: "chevron.up.square")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                        .frame(width: 200, height: 35)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding()
                    }
                    .buttonStyle(PlainButtonStyle())

                }.frame(width: 250)
            }
            
#endif
            
            
            
            
            
        }
        


    }

    
    struct EmailTabButton: View {
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

  

}

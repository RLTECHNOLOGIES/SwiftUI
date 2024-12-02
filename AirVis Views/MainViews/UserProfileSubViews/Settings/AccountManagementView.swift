//
//  AccountManagementView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/17/24.
//
import SwiftUI


struct AccountManagement: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.primary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
   
    }
}


struct AccountManagementView: View {
    @State private var isProcessing = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showDisableConfirmationDialog = false
    @State private var showDeleteConfirmationDialog = false
    @State private var disableConfirmationText = ""
    @State private var deleteConfirmationText = ""
    @EnvironmentObject var appModel : AppModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
#if os(macOS)
        VStack(spacing: 30) {
           
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
                Text("Account Management")
                    .font(.system(size: 18, weight: .regular))
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

            if isProcessing {
                ProgressView("Processing...")
            }
            else
            {
                Button(action: {
                    showDisableConfirmationDialog = true
                }) {
                    HStack {
                        Image(systemName: "hand.raised.slash")
                        Text("Disable Account")
                    }.frame(width: 100)
                }
                .buttonStyle(ElevatedButtonStyle(labelColor: .white, backgroundColor: .black, padding: 10))
                
                Button(action: {
                    showDeleteConfirmationDialog = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Account")
                    }
                    .frame(width: 100)
                }
                .buttonStyle(ElevatedButtonStyle(labelColor: .white, backgroundColor: .red, padding: 10))
                .padding(.bottom)
                
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
                .buttonStyle(CapsuleButtonStyle(labelColor: .white, backgroundColor: .red, padding: 5))
                .padding()
                
            }
        }
        .frame(width: 450)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showDisableConfirmationDialog) {
            DisableConfirmationView(
                disableConfirmationText: $disableConfirmationText,
                onConfirm: {
                    if disableConfirmationText.lowercased() == "disablemyaccount" {
                        disableAccount()
                    } else {
                        showError("You must type 'disablemyaccount' to confirm.")
                    }
                },
                onCancel: {
                    showDisableConfirmationDialog = false
                }
            ).frame(width: 450)
        }
        .sheet(isPresented: $showDeleteConfirmationDialog) {
            DeleteConfirmationView(
                deleteConfirmationText: $deleteConfirmationText,
                onConfirm: {
                    if deleteConfirmationText.lowercased() == "deletemyaccount" {
                        deleteAccount()
                    } else {
                        showError("You must type 'deletemyaccount' to confirm.")
                    }
                },
                onCancel: {
                    showDeleteConfirmationDialog = false
                }
            ).frame(width: 450)
        }
#elseif os(iOS)
        VStack {
           
            HStack {
                Button {
                    withAnimation(.snappy(duration: 0.5)) {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .padding()
                Spacer()
                Text("Account Management")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.blue)
                    .padding(.vertical)
                Spacer()
                Button {
                    withAnimation(.snappy(duration: 0.5)) {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                .padding()
                .opacity(0)
               
            }
           

            if isProcessing {
                ProgressView("Processing...")
            }
            else
            {
                Spacer()
                VStack{
                    Button(action: {
                        showDisableConfirmationDialog = true
                    }) {
                        HStack {
                            Image(systemName: "hand.raised.slash")
                            Text("Disable Account")
                        }.frame(width: 100)
                    }
                    .buttonStyle(ElevatedButtonStyle(labelColor: .white, backgroundColor: .black, padding: 10))
                    .padding()
                    
                    Button(action: {
                        showDeleteConfirmationDialog = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Account")
                        }
                        .frame(width: 100)
                    }
                    .buttonStyle(ElevatedButtonStyle(labelColor: .white, backgroundColor: .red, padding: 10))
                    
                }.padding(.bottom)
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
                .buttonStyle(CapsuleButtonStyle(labelColor: .white, backgroundColor: .red, padding: 5))
                .padding()
                .opacity(0)
                .disabled(true)
                Spacer()
            }
        }
        
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showDisableConfirmationDialog) {
            DisableConfirmationView(
                disableConfirmationText: $disableConfirmationText,
                onConfirm: {
                    if disableConfirmationText.lowercased() == "disablemyaccount" {
                        disableAccount()
                    } else {
                        showError("You must type 'disablemyaccount' to confirm.")
                    }
                },
                onCancel: {
                    showDisableConfirmationDialog = false
                }
            )
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showDeleteConfirmationDialog) {
            DeleteConfirmationView(
                deleteConfirmationText: $deleteConfirmationText,
                onConfirm: {
                    if deleteConfirmationText.lowercased() == "deletemyaccount" {
                        deleteAccount()
                    } else {
                        showError("You must type 'deletemyaccount' to confirm.")
                    }
                },
                onCancel: {
                    showDeleteConfirmationDialog = false
                }
            ).frame(maxWidth: .infinity)
        }
#endif
        
        
    }

    private func disableAccount() {
        
        appModel.deactivateUser {
            result in
                                isProcessing = true
                                    switch result {
                                    case .success:
                                        print("User account deactivated successfully.")
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

                                    case .failure(let error):
                                        print("Failed to deactivate user account: \(error.localizedDescription).")
                                    }
        }

        
        
    }

    private func deleteAccount() {
      
        appModel.deleteUser {
            result in
                                isProcessing = true
                                    switch result {
                                    case .success:
                                        print("User account deleted successfully.")
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

                                    case .failure(let error):
                                        print("Failed to delete user account: \(error.localizedDescription).")
                                    }
        }
        

        
    }


    private func showError(_ message: String) {
        alertTitle = "Error"
        alertMessage = message
        showAlert = true
        isProcessing = false
    }

    private func showSuccess(_ message: String) {
        alertTitle = "Success"
        alertMessage = message
        showAlert = true
        isProcessing = false
    }
}

struct DisableConfirmationView: View {
    @Binding var disableConfirmationText: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm Account Disabling")
                .foregroundColor(.red)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                

            Text(
            """
            Your account will no longer be visible to others, and all your files and information will be inaccessible to other users. To temporarily disable your account, please type 'disablemyaccount' in the field below and tap Confirm.
            
            You can reactivate your account anytime by logging back in.
            """
            )
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            TextField("Type 'disablemyaccount'", text: $disableConfirmationText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                
                
                Button(action: onCancel) {
                    Text("Cancel")
                }

                .buttonStyle(CapsuleButtonStyle(labelColor: .white, backgroundColor: .gray, padding: 5))

                Button(action: onConfirm) {
                    Text("Confirm")
                }

                .buttonStyle(CapsuleButtonStyle(
                    labelColor: .white,
                    backgroundColor: disableConfirmationText.lowercased() == "disablemyaccount" ? .purple : .gray,
                    padding: 5
                ))
                .disabled(disableConfirmationText.lowercased() != "disablemyaccount")
                
                
            }
            
        }
        .padding()
    }
}

struct DeleteConfirmationView: View {
    @Binding var deleteConfirmationText: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("This action is irreversible")
                .foregroundColor(.red)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("""
            All your account data, including any associated content, will be permanently deleted and cannot be recovered.
            
            To permanently delete your account, please type 'deletemyaccount' in the field below and tap Confirm.
            """)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                

            TextField("Type 'deletemyaccount'", text: $deleteConfirmationText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Button(action: onCancel) {
                    Text("Cancel")
                }
                
                .buttonStyle(CapsuleButtonStyle(labelColor: .white, backgroundColor: .gray, padding: 5))

                Button(action: onConfirm) {
                    Text("Confirm")
                }
                
                .buttonStyle(CapsuleButtonStyle(
                    labelColor: .white,
                    backgroundColor: deleteConfirmationText.lowercased() == "deletemyaccount" ? .red : .gray,
                    padding: 5
                ))
                .disabled(deleteConfirmationText.lowercased() != "deletemyaccount")
            }
            .padding()
        }
        .padding()
    }
}

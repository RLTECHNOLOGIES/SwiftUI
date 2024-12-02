//
//  USDZCropPopupView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/15/24.
//


import SceneKit
import SwiftUI


// Popup View
struct USDZCropPopupView: View {
    @Binding var isPresented: Bool
    let fileURL: URL
    let onCapture: (SCNView, String) -> Void  // Pass the file name when capturing
    @StateObject private var viewModel = USDZPopupViewModel()
    @Environment(\.presentationMode) var presentationMode
    // State to hold the entered file name
    @State private var fileName: String = ""
    @StateObject private var keyboardObserver = KeyboardObserver()
    var body: some View {
        
        VStack {
#if os(macOS)
            HStack
            {
                Button {
                    withAnimation(.snappy(duration: 0.5))  {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                }
                .buttonStyle(.plain)
                Spacer()
                Text("Setup a thumbnail for your asset").font(.title).foregroundStyle(.blue)
                Spacer()
                Button {
                    withAnimation(.snappy(duration: 0.5))  {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                }
                .buttonStyle(.plain)
                .opacity(0)
            }.padding()
            HStack{
                // TextField to ask the user for the file name
                VStack {
                    HStack{
                        TextField("Enter The Asset Name", text: $fileName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onReceive(fileName.publisher.collect()) { _ in
                                if fileName.count > 30 {
                                    fileName = String(fileName.dropLast())
                                }
                            }
                        // Disable the button if the file name is empty
                        Button("Upload") {
                            if let sceneView = viewModel.sceneView {
                                onCapture(sceneView, fileName)  // Pass file name with the scene view
                                isPresented = false
                            }
                        }
                        .disabled(fileName.isEmpty)  // Disable the button if the file name is not entered
                        
                        
                    }
                    Text("\(fileName.count)/30 characters")
                        .font(.caption)
                        .foregroundColor(fileName.count >= 30 ? .red : .gray)
                }
                    
              
                
            }.padding()
            ZStack(alignment: .topTrailing){
                SceneKitView(url: fileURL) { view in
                    viewModel.setSceneView(view)
                }
                .frame(width: 600, height: 600)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(12)
                Button {
                    viewModel.recenterCamera()
                } label: {
                    Text("Reset")
                }
                .buttonStyle(ElevatedButtonStyle(labelColor: .gray, backgroundColor: .white, padding: 5))
                .padding()

            }
            Text("Adjust and Crop The Asset for Thumbnail using Trackpad").padding()
#elseif os(iOS)
            HStack {
                         Button {
                             withAnimation(.easeInOut(duration: 0.5)) {
                                 isPresented = false
                             }
                         } label: {
                             Image(systemName: "chevron.left")
                         }
                         .padding()

                         Spacer()

                         Text("Set Thumbnail")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)

                         Spacer()

                         Button {
                             withAnimation(.easeInOut(duration: 0.5)) {
                                 isPresented = false
                             }
                         } label: {
                             Image(systemName: "xmark.circle")
                         }
                         .padding()
                         .opacity(0) // Optional button to align UI
                     }

                     // TextField and Upload Button Section
          

                     // SceneKit View Section
                     ZStack(alignment: .topTrailing) {
                         SceneKitView(url: fileURL) { view in
                             viewModel.setSceneView(view)
                         }
                         .frame(width: 300, height: 300)
                         .background(Color(UIColor.systemBackground))
                         .cornerRadius(12)
                         .overlay(
                                         RoundedRectangle(cornerRadius: 12)
                                             .stroke(Color.black.opacity(0.5), lineWidth: 0.3)
                                     )
                         Button {
                             viewModel.recenterCamera()
                         } label: {
                             Text("Reset")
                         }
                         .buttonStyle(ElevatedButtonStyle(labelColor: .gray, backgroundColor: .white, padding: 5))
                         .padding()
                     }
                     .scaleEffect(keyboardObserver.isKeyboardVisible ? 0.5 : 1)
                     .frame(maxWidth: keyboardObserver.isKeyboardVisible ? 150 : nil)
                     .frame(maxHeight: keyboardObserver.isKeyboardVisible ? 150 : nil)

            VStack(alignment: .center) {
                
                         VStack(alignment: .leading) {
                             TextField("Enter The Asset Name", text: $fileName)
                                 .textFieldStyle(RoundedBorderTextFieldStyle())
                                 .onReceive(fileName.publisher.collect()) { _ in
                                     if fileName.count > 30 {
                                         fileName = String(fileName.prefix(30))
                                     }
                                 }

                             Text("\(fileName.count)/30 characters")
                                 .font(.caption)
                                 .foregroundColor(fileName.count >= 30 ? .red : .gray)
                         }.frame(maxWidth: 300)
                        
                            Button("Upload") {
                                if let sceneView = viewModel.sceneView {
                                    onCapture(sceneView, fileName) // Pass file name with the scene view
                                    isPresented = false
                                }
                            }
                            .buttonStyle(ElevatedButtonStyle(labelColor: .white, backgroundColor: .blue, padding: 5))
                            .disabled(fileName.isEmpty) // Disable the button if the file name is not entered
                        
                
                     }
                     
                     .padding()
                 
            Spacer()
#endif
            
        }
        
    }
}


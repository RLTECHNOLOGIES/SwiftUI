//
//  UploadView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/11/24.
//
import SwiftUI
import FirebaseStorage
import FirebaseAuth
import Firebase
#if os(iOS)
import ARKit
#endif

struct UploadView: View {
    @State private var selectedCategory = "Select a Category"
    @State private var isHovering = false
    @State private var showAlert = false
    @State private var showFileAlert = false
    @State private var fileName: String = ""
    @State private var isFilePickerPresented = false
    @State private var isCapturePresented = false
    @State private var outputFile: URL? = nil
    @State private var newOutputFile: URL? = nil
    @EnvironmentObject var appModel: AppModel
    
    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 10)
    ]
    

    var body: some View {
#if os(macOS)
        ZStack {
            VStack(spacing: 50) {
                
                if appModel.isUploading {
                    VStack(spacing: 10) {
                        Text("Uploading...")
                        ProgressView(value: appModel.uploadProgress, total: 1.0)
                            .padding()
                    }.frame(maxWidth: 800)
                } else if appModel.showUploadSuccessMessage {
                   
                    // Success Message
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green.opacity(0.8))
                            .font(.system(size: 50))
                        
                        Text("Upload Successful!")
                            .font(.title)
                            .foregroundColor(.green.opacity(0.8))
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: appModel.showUploadSuccessMessage)
                } else {
//                    
//                    // Header
                    Text("Share your creations with the world!")
                        .font(.system(size: 24))
                        .foregroundColor(.primary)
                        .padding(.top, 100)
                    // Upload Button
                    Button(action: {
                        if selectedCategory == "Select a Category" {
                            showAlert = true
                        } else {
                            appModel.selectFile()
                        }
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "arrow.up.doc.fill")
                                .font(.system(size: 20))
                            
                            Text("Upload File")
                                .font(.system(size: 15))
                        }
                        .foregroundColor(.white)
                        .frame(width: 200, height: 30)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .scaleEffect(isHovering ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isHovering)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .padding(.horizontal, 150)
                    .padding(.top, -20)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Pick a Category"), message: Text("Please choose a category before uploading file"), dismissButton: .default(Text("OK")))
                    }
                    
                    
                    VStack(alignment: .center) {
               
                        
                        Group {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(appModel.categories, id: \.self) { category in
                                    Text(category)
                                        .font(.subheadline)
                                        .foregroundColor(selectedCategory == category ? .white : .secondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedCategory == category ? Color.black : Color.gray.opacity(0.1))
                                        )
                                        .onTapGesture {
                                            selectedCategory = category
                                            appModel.activeCatergory = category
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: 800) // Constrain the overall width
                    }
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .padding(.horizontal)
                    

                    // Rest of your view remains the same...
                    VStack(spacing: 10) {
                        Text("Supported Format")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("USDZ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    .padding(.top, 10)
                }
                
                
            
            }
            .onChange(of: selectedCategory) { oldValue, category in
                appModel.activeCatergory = category
            }

            .sheet(isPresented: $appModel.showUSDZCropView) {
                        if let fileURL = appModel.selectedFileURL {
                            USDZCropPopupView(
                                isPresented: $appModel.showUSDZCropView,
                                fileURL: fileURL,
                                onCapture: { sceneView,fileName in
                                    appModel.captureThumbnail(from: sceneView, fileName: fileName)
                                }
                            )
                        }
                    }
        }
#elseif os(iOS)
        ZStack {
            VStack(spacing: 40) {
                
                if appModel.isUploading {
                    VStack(spacing: 10) {
                        Text("Uploading...")
                        ProgressView(value: appModel.uploadProgress, total: 1.0)
                            .padding()
                    }.frame(maxWidth: 800)
                } else if appModel.showUploadSuccessMessage {
                   
                    // Success Message
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green.opacity(0.8))
                            .font(.system(size: 50))
                        
                        Text("Upload Successful!")
                            .font(.title)
                            .foregroundColor(.green.opacity(0.8))
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: appModel.showUploadSuccessMessage)
                } else {
                    
                    Spacer()
//                    // Header
//                    Text("Share your creations")
//                        .font(.system(size: 24))
//                        .foregroundColor(.primary)
//                    Spacer()
                    // Capture Button
                    if #available(iOS 18, *) {
                        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                            
                            
                            Spacer()
                            Button(action: {
                                
                                isCapturePresented = true
                                
                            }) {
                                HStack(spacing: 15) {
                                    Image(systemName: "arkit")
                                        .font(.system(size: 20))
                                    
                                    Text("Capture Object")
                                        .font(.system(size: 15))
                                }
                                .fullScreenCover(isPresented: $isCapturePresented) {
                                    PrimaryView(outputFile: $outputFile).environment(AppDataModel.instance)
                                        .onDisappear {
                                            if(outputFile != nil && outputFile != newOutputFile)
                                            {
                                                appModel.selectedFileURL = outputFile
                                                appModel.showUSDZCropView = true
                                                newOutputFile = outputFile
                                                
                                            }
                                        }
                                }
                                .foregroundColor(.white)
                                .frame(width: 200, height: 30)
                                .padding(.vertical, 10)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing)
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 150)
                            .padding(.top, -20)
                            
                        }
                    }
                    // Upload Button
                    Button(action: {
                        if selectedCategory == "Select a Category" {
                            showAlert = true
                        } else {
                            isFilePickerPresented = true
                        }
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "arrow.up.doc.fill")
                                .font(.system(size: 20))
                            
                            Text("Upload File")
                                .font(.system(size: 15))
                        }
                        .sheet(isPresented: $isFilePickerPresented) {
                            FileSelector { url in
                            if let url = url {
                                                  appModel.selectedFileURL = url
                                                  appModel.showUSDZCropView = true
                                              }
                                        else {
                                            
                                                showFileAlert = true
                                            
                                              }
                                          }
                                   }
                        
                        .foregroundColor(.white)
                        .frame(width: 200, height: 30)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .scaleEffect(isHovering ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isHovering)
                        .sheet(isPresented: $showFileAlert) {
                            VStack{
                                Text("Please select a USDZ file below 100MB").font(.system(size: 20)).multilineTextAlignment(.center).foregroundStyle(.gray)
                            }
                            .presentationDetents([.height(150)])
//                                   Alert(title: Text("Error"), message: Text("Please select a USDZ file below 100MB"), dismissButton: .default(Text("OK")))
                               }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .padding(.horizontal, 150)
                    .padding(.top, -20)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Pick a Category"), message: Text("Please choose a category before uploading file"), dismissButton: .default(Text("OK")))
                    }
                    
                    
                    
                    
                    VStack(alignment: .center) {
               
                        
                        List {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(appModel.categories, id: \.self) { category in
                                    Text(category)
                                        .font(.subheadline)
                                        .foregroundColor(selectedCategory == category ? .white : .secondary)
                                        .frame(maxWidth: 200)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedCategory == category ? Color.black : Color.gray.opacity(0.1))
                                        )
                                        .onTapGesture {
                                            selectedCategory = category
                                            appModel.activeCatergory = category
                                        }
                                }
                            }.listRowSeparator(.hidden)
                        }
                        .listStyle(PlainListStyle())
                        .frame(maxWidth: 800) // Constrain the overall width
                    }
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .padding(.horizontal)
                    

                    
                    VStack(spacing: 5) {
                        Text("Supported Format")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("USDZ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                
                
            
            }
            .onChange(of: selectedCategory) { oldValue, category in
                appModel.activeCatergory = category
            }

            .fullScreenCover(isPresented: $appModel.showUSDZCropView) {
                        if let fileURL = appModel.selectedFileURL {
                            USDZCropPopupView(
                                isPresented: $appModel.showUSDZCropView,
                                fileURL: fileURL,
                                onCapture: { sceneView,fileName in
                                    appModel.captureThumbnail(from: sceneView, fileName: fileName)
                                }
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
        }
        #endif
    }
}

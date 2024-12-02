//
//  USDZPreview.swift
//  AirVis
//
//  Created by Arun Kurian on 11/13/24.
//
import SwiftUI
import SceneKit
#if os(iOS)
import ARKit
#endif
struct USDZPreview: View {
    var file: File

    @StateObject private var viewModel = USDZPopupViewModel()
    @State var validURL: URL?
    @State var isVisible = false // Controls opacity for animations
    @EnvironmentObject var appModel: AppModel
    @State var downloadError: String?
    @State var usernameHovered: Bool = false
    @State var resetHovered: Bool = false
    @Binding var userSheetPresented: Bool
    @State var isLoading: Bool = true // Set initial state to loading
    @State var arView: Bool = false
    
    var size: CGFloat

    var body: some View {
        VStack {
            if isLoading {
                // Display loading state
                ProgressView()
                    .frame(width: size, height: size)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: isLoading)
            } else if let error = downloadError {
                // Display download error message
                VStack {
                    Text("Unable to load model\nPlease try again later")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                        .padding()
                    Button("Retry") {
                        // Retry download
                        downloadAndSetLocalURL()
                    }
                    .padding(.top, 10)
                }
                .frame(width: size, height: size)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            }
            else if let url = validURL {
                        VStack {
                            ZStack(alignment: .topTrailing) {
                                
                                
                                SceneKitView(url: url, onViewCreated: { view in
                                    viewModel.setSceneView(view)
                                })
                                .frame(width: size, height: size)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                                .opacity(isVisible ? 1 : 0) // Animate opacity
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        isVisible = true
                                    }
                                }
                                
#if os(iOS)
                                if ARWorldTrackingConfiguration.isSupported {
                                    
                                    Button
                                    {
                                        arView = true
                                    }label:
                                    {
                                        Image(systemName: "arkit").font(.system(size: 22))
                                    }
                                    .padding(7)
                                }
#elseif os(macOS)
                                    Button(action: viewModel.recenterCamera) {
                                        Text("Reset")
                                    }
                                    .scaleEffect(resetHovered ? 1.0 : 0.9)
                                    .buttonStyle(ElevatedButtonStyle(labelColor: .gray, backgroundColor: .white, padding: 5))
                                    .padding(5)
#endif
                                
//                                .frame(width: 290)
                                
                                
                            }
                            HStack {
                                HStack {
                                    Image(systemName: "person.circle")
                                        .foregroundStyle(Color.blue)
                                    Text(displayCappedText(file.uploaderName, limit: 20))
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .padding(.trailing, 2)
                                }
                                .padding(5)
                                .clipShape(Capsule())
                                .background(Capsule().stroke(Color.blue, lineWidth: 1))
                            }
                            .scaleEffect(usernameHovered ? 1.0 : 0.9)
                            .onHover { hovered in
                                if !appModel.inAuthorProfile && !appModel.myFile {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        usernameHovered = hovered
                                    }
                                }
                            }
                            .onTapGesture {
                                if !appModel.inAuthorProfile && !appModel.myFile {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        userSheetPresented = true
                                    }
                                }
                            }
                            .padding(.top, 2)
                        }
                    
                    
                 
                
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $arView)
        {
            ARQuickLookView(
                                modelFileURL:  validURL ?? URL(string: file.fileURL)!,
                                onDismiss: {
                                    arView = false
                                }
                            )
        }
#endif
        .onAppear(perform: downloadAndSetLocalURL)
        .padding()
    }

    func downloadAndSetLocalURL() {
        guard let url = URL(string: file.fileURL) else {
            downloadError = "Invalid URL."
            isLoading = false
            return
        }

        isLoading = true // Start loading

        if url.scheme == "http" || url.scheme == "https" {
            appModel.downloadOrRetrieveUSDZFile(from: url, saveToDownloads: false) { localURL, error in
                DispatchQueue.main.async {
                    if let error = error {
                        downloadError = "Download error: \(error.localizedDescription)"
                        validURL = nil
                    } else if let localURL = localURL {
                        self.validURL = localURL
                        downloadError = nil // Clear any previous error
                    }
                    isLoading = false // Stop loading
                }
            }
        } else {
            downloadError = "Invalid URL scheme."
            isLoading = false
        }
    }
}

//
//  PopUp.swift
//  AirVis
//
//  Created by Arun Kurian on 11/18/24.
//

import SwiftUI

struct PopOverDetailedView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var isHoveringReport = false
    @State private var isHoveringSave = false
    @State private var isHoveringDelete = false
    @State private var showAlert = false
    @State private var showReportSheet = false
    @State private var actionType: ActionType?
    @State private var reportReason = ""
    @State var downloadError = ""
    @State private var showSaveAlert = false
    @State var saveAlertMessage = ""
    @State var saveAlertTitle = ""

    var file: File
    @Binding var isPresented: Bool
    
    enum ActionType {
        case save, delete, report, message
    }
    
    var body: some View {
#if os(macOS)
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
            VStack(alignment: .center, spacing: 0) {
                // Save Button
                HStack(alignment: .bottom, spacing: 2) {
                    Image(systemName: "arrow.down.circle")
                    Text("Save")
                        .font(.system(size: 12, weight: .light))
                }
                .foregroundStyle(.blue)
                .padding(8)
                .scaleEffect(isHoveringSave ? 1.1 : 1.0)
                .onHover { hovering in
                    isHoveringSave = hovering
                }
                .onTapGesture {
                    actionType = .save
                    showAlert = true
                }
                
                if appModel.myFile {
                    Divider()
                    // Delete Button
                    HStack(alignment: .bottom, spacing: 2) {
                        Image(systemName: "xmark.bin")
                        Text("Delete")
                            .font(.system(size: 12, weight: .light))
                    }
                    .foregroundStyle(.red)
                    .padding(8)
                    .scaleEffect(isHoveringDelete ? 1.1 : 1.0)
                    .onHover { hovering in
                        isHoveringDelete = hovering
                    }
                    .onTapGesture {
                        actionType = .delete
                        showAlert = true
                    }
                } else {
                    Divider()
                    // Report Button
                    HStack(alignment: .bottom, spacing: 2) {
                        Image(systemName: "flag")
                        Text("Report")
                            .font(.system(size: 12, weight: .light))
                    }
                    .foregroundStyle(.red)
                    .padding(8)
                    .scaleEffect(isHoveringReport ?  1.1 : 1.0)
                    .onHover { hovering in
                        isHoveringReport = hovering
                    }
                    .onTapGesture {
                        actionType = .report
                        showReportSheet = true
                    }.popover(isPresented: $showReportSheet, arrowEdge: .bottom) {
                        
                        VStack{
                            TextField("Reason for reporting", text: $reportReason)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    appModel.addFileReport(for: file, reason: reportReason) { _ in
                                        isPresented = false
                                    }
                                    showReportSheet = false
                                }
                            Button("Report") {
                                appModel.addFileReport(for: file, reason: reportReason) { _ in
                                    isPresented = false
                                }
                                showReportSheet = false
                            }.disabled(reportReason.isEmpty)
                        }.padding()
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            switch actionType {
            case .save:
                return Alert(
                    title: Text("Confirm Save"),
                    message: Text("Are you sure you want to save this file?"),
                    primaryButton: .default(Text("Yes")) {
                        isPresented = false
                        downloadToDownloads()
                        
                        print(downloadError)
                    }
                    ,
                    secondaryButton: .cancel()
                )
            case .delete:
                return Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to delete this file?"),
                    primaryButton: .destructive(Text("Delete")) {
                        appModel.deleteFile(file: file) { _ in
                            isPresented = false
                            appModel.getAllUploadedFiles()
                        }
                    },
                    secondaryButton: .cancel()
                )
            default:
                return Alert(title: Text("Error")) // Fallback in case of error
            }
        }
        
#elseif os(iOS)
      
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            VStack(alignment: .leading, spacing: 0) {
                // Save Button
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle")
                    Text("Save")
                        .font(.system(size: 16, weight: .regular))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 40)
                .foregroundStyle(.blue)
                .padding(10)
                .scaleEffect(isHoveringSave ? 1.1 : 1.0)
                .onHover { hovering in
                    isHoveringSave = hovering
                }
                .onTapGesture {
                    actionType = .save
                    showAlert = true
                }
                if appModel.myFile {
                    Divider()
                    // Delete Button
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.bin")
                        Text("Delete")
                            .font(.system(size: 16, weight: .regular))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 40)
                    .foregroundStyle(.red)
                    .padding(10)
                    .scaleEffect(isHoveringDelete ? 1.1 : 1.0)
                    .onHover { hovering in
                        isHoveringDelete = hovering
                    }
                    .onTapGesture {
                        actionType = .delete
                        showAlert = true
                    }
                }
                else {
                    Divider()
                    // Report Button
                    HStack(spacing: 8) {
                        Image(systemName: "flag")
                        Text("Report")
                            .font(.system(size: 16, weight: .regular))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 40)
                    .foregroundStyle(.red)
                    .padding(10)
                    .scaleEffect(isHoveringReport ?  1.1 : 1.0)
                    .onHover {
                        hovering in
                        isHoveringReport = hovering
                    }
                    .onTapGesture {
                        actionType = .report
                        showReportSheet = true
                    }
                    .sheet(isPresented: $showReportSheet) {
                        
                        VStack{
                            TextField("Reason for reporting", text: $reportReason)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    appModel.addFileReport(for: file, reason: reportReason) { _ in
                                        isPresented = false
                                    }
                                    showReportSheet = false
                                }
                            Button("Report") {
                                appModel.addFileReport(for: file, reason: reportReason) { _ in
                                    isPresented = false
                                }
                                showReportSheet = false
                            }.disabled(reportReason.isEmpty)
                        }
                        .padding()
                        .presentationDetents([.height(120)])
                        .presentationDragIndicator(.hidden) // Adds a drag indicator to allow user to swipe down to dismiss
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                switch actionType {
                case .save:
                    return Alert(
                        title: Text("Confirm Save"),
                        message: Text("Are you sure you want to save this file?"),
                        primaryButton: .default(Text("Yes")) {
                            downloadToDocuments()
                        }
                        ,
                        secondaryButton: .cancel()
                    )
                case .delete:
                    return Alert(
                        title: Text("Confirm Delete"),
                        message: Text("Are you sure you want to delete this file?"),
                        primaryButton: .destructive(Text("Delete")) {
                            appModel.deleteFile(file: file) { _ in
                                isPresented = false
                                appModel.getAllUploadedFiles()
                            }
                        },
                        secondaryButton: .cancel()
                    )
                    
                case .message:
                    return Alert(
                      title: Text("\(saveAlertMessage)"),
                      message: Text("\(saveAlertTitle)"),
                      primaryButton: .default(Text("OK"))
                      {
                          isPresented = false
                            
                      },
                      secondaryButton: .cancel()
                    )
                default:
                    return Alert(title: Text("Error")) // Fallback in case of error
                }
            }
            
        }
      else // IPAD
        {
          
              VStack(spacing: 0) {
                  // Save Button
                  HStack(spacing: 8) {
                      Image(systemName: "arrow.down.circle")
                      Text("Save")
                          .font(.system(size: 16, weight: .regular))
                  }
                  .frame(maxWidth: .infinity)
                  .frame(minHeight: 40)
                  .foregroundStyle(.blue)
                  .padding(10)
                  .scaleEffect(isHoveringSave ? 1.1 : 1.0)
                  .onHover { hovering in
                      isHoveringSave = hovering
                  }
                  .onTapGesture {
                      actionType = .save
                      showAlert = true
                  }
                  if appModel.myFile {
                      Divider()
                      // Delete Button
                      HStack(spacing: 8) {
                          Image(systemName: "xmark.bin")
                          Text("Delete")
                              .font(.system(size: 16, weight: .regular))
                      }
                      .frame(maxWidth: .infinity)
                      .frame(minHeight: 40)
                      .foregroundStyle(.red)
                      .padding(10)
                      .scaleEffect(isHoveringDelete ? 1.1 : 1.0)
                      .onHover { hovering in
                          isHoveringDelete = hovering
                      }
                      .onTapGesture {
                          actionType = .delete
                          showAlert = true
                      }
                  }
                  else {
                      Divider()
                      // Report Button
                      HStack(spacing: 8) {
                          Image(systemName: "flag")
                          Text("Report")
                              .font(.system(size: 16, weight: .regular))
                      }
                      .frame(maxWidth: .infinity)
                      .frame(minHeight: 40)
                      .foregroundStyle(.red)
                      .padding(10)
                      .scaleEffect(isHoveringReport ?  1.1 : 1.0)
                      .onHover {
                          hovering in
                          isHoveringReport = hovering
                      }
                      .onTapGesture {
                          actionType = .report
                          showReportSheet = true
                      }
                      .sheet(isPresented: $showReportSheet) {
                          
                          VStack{
                              TextField("Reason for reporting", text: $reportReason)
                                  .textFieldStyle(RoundedBorderTextFieldStyle())
                                  .onSubmit {
                                      appModel.addFileReport(for: file, reason: reportReason) { _ in
                                          isPresented = false
                                      }
                                      showReportSheet = false
                                  }
                              Button("Report") {
                                  appModel.addFileReport(for: file, reason: reportReason) { _ in
                                      isPresented = false
                                  }
                                  showReportSheet = false
                              }.disabled(reportReason.isEmpty)
                          }
                          .padding()
                          .presentationDetents([.height(120)])
                          .presentationDragIndicator(.hidden) // Adds a drag indicator to allow user to swipe down to dismiss
                          .frame(maxWidth: .infinity)
                      }
                  }
              }
              .alert(isPresented: $showAlert) {
                  switch actionType {
                  case .save:
                      return Alert(
                          title: Text("Confirm Save"),
                          message: Text("Are you sure you want to save this file?"),
                          primaryButton: .default(Text("Yes")) {
                              
                                  downloadToDocuments()
                              
                          }
                          ,
                          secondaryButton: .cancel()
                      )
                  case .delete:
                      return Alert(
                          title: Text("Confirm Delete"),
                          message: Text("Are you sure you want to delete this file?"),
                          primaryButton: .destructive(Text("Delete")) {
                              appModel.deleteFile(file: file) { _ in
                                  isPresented = false
                                  appModel.getAllUploadedFiles()
                              }
                          },
                          secondaryButton: .cancel()
                      )
                  case .message:
                      return Alert(
                        title: Text("\(saveAlertMessage)"),
                        message: Text("\(saveAlertTitle)"),
                        primaryButton: .default(Text("OK"))
                        {
                            isPresented = false
                        },
                        secondaryButton: .cancel()
                      )
                  default:
                      return Alert(title: Text("Error")) // Fallback in case of error
                  }
              }
              
              
          
      }
#endif
    }
    
#if os(macOS)
    func downloadToDownloads() {
        guard let url = URL(string: file.fileURL) else {
            showAlert(message: "Download Error", informativeText: "Invalid URL.")
            return
        }

        if url.scheme == "http" || url.scheme == "https" {
            // Locate the Downloads directory
            guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
                showAlert(message: "Error", informativeText: "Failed to locate Downloads directory.")
                return
            }

            // Generate the initial save path with .usdz extension
            var saveURL = downloadsURL.appendingPathComponent(url.lastPathComponent)
            if saveURL.pathExtension != "usdz" {
                saveURL.appendPathExtension("usdz")
            }

            // Resolve naming conflicts by appending a suffix if necessary
            saveURL = resolveNamingConflict(for: saveURL)

            // Download and save the file directly to the Downloads directory
            appModel.downloadOrRetrieveUSDZFile(from: url, saveToDownloads: false) { localURL, error in
                if let error = error {
                    showAlert(message: "Download Error", informativeText: error.localizedDescription)
                } else if let localURL = localURL {
                    do {
                        // Copy the downloaded file to the resolved save location
                        try FileManager.default.copyItem(at: localURL, to: saveURL)

                        // Inform the user of the successful download
                        showAlert(message: "Download Successful", informativeText: "The file has been saved to your Downloads folder.")
                    } catch {
                        showAlert(message: "Save Error", informativeText: error.localizedDescription)
                    }
                }
            }
        } else {
            showAlert(message: "Unsupported URL", informativeText: "Please use a URL with http or https scheme.")
        }
    }

    func resolveNamingConflict(for url: URL) -> URL {
        var uniqueURL = url
        var counter = 1

        while FileManager.default.fileExists(atPath: uniqueURL.path) {
            // Modify the file name to include a counter (e.g., filename_1.usdz)
            let baseName = uniqueURL.deletingPathExtension().lastPathComponent
            let directory = uniqueURL.deletingLastPathComponent()
            let newFileName = "\(baseName)_\(counter)"
            uniqueURL = directory.appendingPathComponent(newFileName).appendingPathExtension("usdz")
            counter += 1
        }

        return uniqueURL
    }

    func showAlert(message: String, informativeText: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = informativeText
        alert.alertStyle = .warning // You can set it to .informational or .critical based on your needs
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
#elseif os(iOS)
    func downloadToDocuments() {
        
        guard let url = URL(string: file.fileURL) else {
            
            saveAlertTitle = "Invalid URL."
            saveAlertMessage = "Error"
            return
        }

        if url.scheme == "http" || url.scheme == "https" {
            
            
            // Locate the Documents directory
            guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                saveAlertTitle = "Failed to locate Documents directory."
                saveAlertMessage = "Error"
                return
            }
            
            // Generate the full save path with .usdz extension
            var saveURL = documentsURL.appendingPathComponent(url.lastPathComponent)
            if saveURL.pathExtension != "usdz" {
                saveURL.appendPathExtension("usdz")
            }
            
            // Resolve naming conflicts by appending a suffix if necessary
            saveURL = resolveNamingConflict(for: saveURL)
            
            // Download and save the file directly to the Documents directory
            appModel.downloadOrRetrieveUSDZFile(from: url, saveToDownloads: false) { localURL, error in
                DispatchQueue.main.async { // Ensure updates happen on the main thread
                    if let error = error {
                        saveAlertTitle = error.localizedDescription
                        saveAlertMessage = "Download Error"
                    } else if let localURL = localURL {
                        do {
                            // Copy the downloaded file to the resolved save location
                            try FileManager.default.copyItem(at: localURL, to: saveURL)
                            saveAlertTitle = "The file has been saved to your Documents folder."
                            saveAlertMessage = "Download Successful"
                        } catch {
                            saveAlertTitle = error.localizedDescription
                            saveAlertMessage = "Save Error"
                        }
                    }
                    
                    print(saveAlertTitle)
                    print(saveAlertMessage)
                    showAlert = true
                    actionType = .message
                }
            }

        } else {
            
            saveAlertTitle = "Please use a URL with http or https scheme."
            saveAlertMessage = "Unsupported URL"
            
        }
    }

    func resolveNamingConflict(for url: URL) -> URL {
        var uniqueURL = url
        var counter = 1

        while FileManager.default.fileExists(atPath: uniqueURL.path) {
            // Modify the file name to include a counter (e.g., filename_1.usdz)
            let baseName = uniqueURL.deletingPathExtension().lastPathComponent
            let directory = uniqueURL.deletingLastPathComponent()
            let newFileName = "\(baseName)_\(counter)"
            uniqueURL = directory.appendingPathComponent(newFileName).appendingPathExtension("usdz")
            counter += 1
        }

        return uniqueURL
    }

    


#endif

}

struct DetailedBottomTab: View {
    var file: File
    
    @Binding var showFullName: Bool
    @StateObject private var keyboardObserver = KeyboardObserver()
    @EnvironmentObject var appModel: AppModel
    @State var trashAnimation: Bool = false
    @State var editAnimation: Bool = false
    @State var favAnimation: Bool = false
    @State var upAnimation: Bool = false
    @State var hasUpvoted: Bool = false  // Track upvote status
    @State var totalUpvotes: Int = 0
    @State var hasfavorited: Bool = false
    @State var totalfavorites: Int = 0
    @Binding var commentExpanded: Bool
    @State var totalComments: Int = 0
    // Track hover states
     @State private var isHoveringfavorite = false
     @State private var isHoveringUpvote = false
     @State private var isHoveringComment = false
    @State private var showAlert = false
     @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        
#if os(macOS)
        VStack {
            HStack {
                // Stats section with fixed width
                HStack(spacing: 0) {
                    HStack(spacing: 3) {
                        Image(systemName: hasfavorited ? "star.fill": "star")
                            .symbolEffect(.bounce, value: favAnimation)
                            .foregroundStyle(Color.yellow)
                            .scaleEffect(isHoveringfavorite ? 1.3 : 1.0)
                        Text(formatNumber(totalfavorites))
                            .foregroundStyle(.gray)
                    }
                    .alert(isPresented: $showAlert) {
                              Alert(
                                  title: Text("Action Not Allowed"),
                                  message: Text(alertMessage),
                                  dismissButton: .default(Text("OK"))
                              )
                          }
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1))
                        {
                            isHoveringfavorite = hovering
                        }
                    }
                    
//                    .frame(width: 65)
                    .padding(3)
                    
                    .onTapGesture {
                        favAnimation.toggle()
                        appModel.savefavorites(file: file, completion: { favoritesAdded in
                            self.hasfavorited = favoritesAdded
                            if(favoritesAdded)
                            {
                                self.hasfavorited = favoritesAdded
                                totalfavorites += 1
                            }
                            else if (!favoritesAdded && totalfavorites > 0 && !appModel.myFile)
                            {
                                totalfavorites -= 1
                                    withAnimation(.snappy(duration: 0.5))  {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                            }
                            DispatchQueue.main.async {
                                // Find the index of the file in uploadedFiles
                                if let index = appModel.favoritedFiles.firstIndex(where: { $0.id == file.id }) {
                                    // Update the upvote count and status locally in uploadedFiles
                                    if favoritesAdded {
                                        appModel.favoritedFiles[index].favoritesCount += 1
                                    } else {
                                        appModel.favoritedFiles[index].favoritesCount -= 1
                                        appModel.favoritedFiles.remove(at: index)
                                    }
                                    
                                }
                            }
                            
                        }, showAlert: { message in
                            alertMessage = message
                            showAlert = true
                            
                        })
                        
                    }
                    // Upvote section
                    HStack(spacing: 3) {
                        Image(systemName: hasUpvoted ? "heart.fill" : "heart")
                            .symbolEffect(.bounce, value: upAnimation)
                            .foregroundStyle(Color.red)  // Change color based on upvote status
                            .scaleEffect(isHoveringUpvote ? 1.3 : 1.0)
                        Text(formatNumber(totalUpvotes))
                            .foregroundStyle(.gray)
                    }
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isHoveringUpvote = hovering
                        }
                    }
                    
                    .padding(3)
                    .onTapGesture {
                        upAnimation.toggle()
                        appModel.toggleUpvote(fileID: file.id) { upvoteAdded in
                            // Update the upvote status based on toggle result
                            self.hasUpvoted = upvoteAdded
                            if(upvoteAdded)
                            {
                                totalUpvotes += 1
                            }
                            else if (!upvoteAdded && totalUpvotes > 0)
                            {
                                totalUpvotes -= 1
                            }
                            DispatchQueue.main.async {
                                // Find the index of the file in uploadedFiles
                                if let index = appModel.uploadedFiles.firstIndex(where: { $0.id == file.id }) {
                                    // Update the upvote count and status locally in uploadedFiles
                                    if upvoteAdded {
                                        appModel.uploadedFiles[index].totalUpvoteCount += 1
                                    } else {
                                        appModel.uploadedFiles[index].totalUpvoteCount -= 1
                                    }
                                    
                                }
                            }
                        }
                    }
                    HStack(spacing: 3) {
                        Image(systemName: "message")  // Use filled flame for upvoted status
                            .foregroundStyle(.gray)
                            .symbolEffect(.bounce, value: commentExpanded)
                            .scaleEffect(isHoveringComment ? 1.3 : 1.0)
                        Text(formatNumber(totalComments))
                            .foregroundStyle(.gray)
                    }
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1))
                        {
                            isHoveringComment = hovering
                        }
                        }
                    .padding(3)
                    
                    .onTapGesture {
                       
                        if (commentExpanded)
                        {
                            withAnimation(.smooth(duration: 0.3))
                            {
                                commentExpanded = false
                            }
                        }
                        else
                        {
                            withAnimation(.smooth(duration: 0.3))
                            {
                                commentExpanded = true
                            }
                            
                        }
                        
                    }
                }
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.clear, lineWidth: 0)
            )
            Group{
                if(commentExpanded)
                {
                    CommentsView(file: file, commentCount: $totalComments).environmentObject(appModel)
                }
            }
        }
        .onAppear {
            
            // Check upvote status on view load
            appModel.checkIfUserHasUpvoted(fileID: file.id) { hasUpvoted in
                self.hasUpvoted = hasUpvoted
            }
            totalUpvotes = file.totalUpvoteCount
            
            appModel.checkIfUserHasfavorited(fileID: file.id) { hasfavorited in
                self.hasfavorited = hasfavorited
            }
            //Check if user favorited
            totalfavorites = file.favoritesCount
            
            totalComments = file.commentsCount
        }
        .onChange(of: appModel.inAuthorProfile) { oldValue, newValue in
            if newValue
            {
                commentExpanded = false
            }
        }
        #elseif os(iOS)
        VStack {
            HStack {
                // Stats section with fixed width
                HStack(spacing: 0) {
                    HStack(spacing: 3) {
                        Image(systemName: hasfavorited ? "star.fill": "star")
                            .symbolEffect(.bounce, value: favAnimation)
                            .foregroundStyle(Color.yellow)
                            .scaleEffect(isHoveringfavorite ? 1.3 : 1.0)
                        Text(formatNumber(totalfavorites))
                            .foregroundStyle(.gray)
                    }
                    .alert(isPresented: $showAlert) {
                              Alert(
                                  title: Text("Action Not Allowed"),
                                  message: Text(alertMessage),
                                  dismissButton: .default(Text("OK"))
                              )
                          }
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1))
                        {
                            isHoveringfavorite = hovering
                        }
                    }
                    
//                    .frame(width: 65)
                    .padding(3)
                    
                    .onTapGesture {
                        favAnimation.toggle()
                        appModel.savefavorites(file: file, completion: { favoritesAdded in
                            self.hasfavorited = favoritesAdded
                            if(favoritesAdded)
                            {
                                self.hasfavorited = favoritesAdded
                                totalfavorites += 1
                            }
                            else if (!favoritesAdded && totalfavorites > 0 && !appModel.myFile)
                            {
                                totalfavorites -= 1
                                    withAnimation(.snappy(duration: 0.5))  {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                            }
                            DispatchQueue.main.async {
                                // Find the index of the file in uploadedFiles
                                if let index = appModel.favoritedFiles.firstIndex(where: { $0.id == file.id }) {
                                    // Update the upvote count and status locally in uploadedFiles
                                    if favoritesAdded {
                                        appModel.favoritedFiles[index].favoritesCount += 1
                                    } else {
                                        appModel.favoritedFiles[index].favoritesCount -= 1
                                        appModel.favoritedFiles.remove(at: index)
                                    }
                                    
                                }
                            }
                            
                        }, showAlert: { message in
                            alertMessage = message
                            showAlert = true
                            
                        })
                        
                    }
                    // Upvote section
                    HStack(spacing: 3) {
                        Image(systemName: hasUpvoted ? "heart.fill" : "heart")
                            .symbolEffect(.bounce, value: upAnimation)
                            .foregroundStyle(Color.red)  // Change color based on upvote status
                            .scaleEffect(isHoveringUpvote ? 1.3 : 1.0)
                        Text(formatNumber(totalUpvotes))
                            .foregroundStyle(.gray)
                    }
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isHoveringUpvote = hovering
                        }
                    }
                    
                    .padding(3)
                    .onTapGesture {
                        upAnimation.toggle()
                        appModel.toggleUpvote(fileID: file.id) { upvoteAdded in
                            // Update the upvote status based on toggle result
                            self.hasUpvoted = upvoteAdded
                            if(upvoteAdded)
                            {
                                totalUpvotes += 1
                            }
                            else if (!upvoteAdded && totalUpvotes > 0)
                            {
                                totalUpvotes -= 1
                            }
                            DispatchQueue.main.async {
                                // Find the index of the file in uploadedFiles
                                if let index = appModel.uploadedFiles.firstIndex(where: { $0.id == file.id }) {
                                    // Update the upvote count and status locally in uploadedFiles
                                    if upvoteAdded {
                                        appModel.uploadedFiles[index].totalUpvoteCount += 1
                                    } else {
                                        appModel.uploadedFiles[index].totalUpvoteCount -= 1
                                    }
                                    
                                }
                            }
                        }
                    }
                    HStack(spacing: 3) {
                        Image(systemName: "message")  // Use filled flame for upvoted status
                            .foregroundStyle(.gray)
                            .symbolEffect(.bounce, value: commentExpanded)
                            .scaleEffect(isHoveringComment ? 1.3 : 1.0)
                        Text(formatNumber(totalComments))
                            .foregroundStyle(.gray)
                    }
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1))
                        {
                            isHoveringComment = hovering
                        }
                        }
                    .padding(3)
                    
                    .onTapGesture {
                       
                        if (commentExpanded)
                        {
                            withAnimation(.smooth(duration: 0.3))
                            {
                                commentExpanded = false
                            }
                        }
                        else
                        {
                            withAnimation(.smooth(duration: 0.3))
                            {
                                commentExpanded = true
                            }
                            
                        }
                        
                    }
                }
                
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.clear, lineWidth: 0)
            )
            .scaleEffect(keyboardObserver.isKeyboardVisible ? 0.6 : 1)
            Group{
                if(commentExpanded)
                {
                    CommentsView(file: file, commentCount: $totalComments).environmentObject(appModel)
                }
            }
            .transition(.scale)
            .frame(maxWidth: commentExpanded ? 500 : 0.01)
        }
        .onAppear {
            
            // Check upvote status on view load
            appModel.checkIfUserHasUpvoted(fileID: file.id) { hasUpvoted in
                self.hasUpvoted = hasUpvoted
            }
            totalUpvotes = file.totalUpvoteCount
            
            appModel.checkIfUserHasfavorited(fileID: file.id) { hasfavorited in
                self.hasfavorited = hasfavorited
            }
            //Check if user favorited
            totalfavorites = file.favoritesCount
            totalComments = file.commentsCount
        }
        .onChange(of: appModel.inAuthorProfile) { oldValue, newValue in
            if newValue
            {
                commentExpanded = false
            }
        }
      
#endif
    }
}


//
//  SearchView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/11/24.
//
import SwiftUI
import FirebaseFirestore

struct SearchView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var searchText = ""
    @State private var isLoading: Bool = false
    @FocusState private var isFocused: Bool
    @State private var isHovering: Bool = false
    @State private var searchFilesResults: [File] = []
    @State private var searchUsersResults: [User] = []
    @State private var lastDocumentSnapshot: QueryDocumentSnapshot? = nil
    @State private var notFound: Bool = false
    @FocusState private var isTextFieldFocused: Bool // Use FocusState with an optional Bool
    @State private var searchTypeFile: Bool = true
    
    let pageSize = 10
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = false
                }
            
            VStack {
                Spacer()
                VStack{
                   
                    if(searchTypeFile)
                    {
                        // Header
                        Text("What do you want to search for ?")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                            .padding()
                            .opacity(searchFilesResults.isEmpty && searchText.isEmpty ? 1 : 0)
                            .scaleEffect(searchFilesResults.isEmpty && searchText.isEmpty ? 1 : 0.75)
                            .animation(.smooth(duration: 1.0), value: searchText)
                            .transition(.scale)
                    }
                    else
                    {
                        Text("Who are you looking for?")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                            .padding()
                            .opacity(searchUsersResults.isEmpty && searchText.isEmpty ? 1 : 0)
                            .scaleEffect(searchUsersResults.isEmpty && searchText.isEmpty ? 1 : 0.75)
                            .animation(.smooth(duration: 1.0), value: searchText)
                            .transition(.scale)
                    }
                    // Search bar container
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation {
                                searchTypeFile.toggle()
                                searchFilesResults = []
                                searchUsersResults = []
                                searchText = ""
                                appModel.lastSearchTerm = ""
                            }
                        }) {
                            if searchTypeFile {
                                Image(systemName: "arkit").font(.system(size: 18))
                                    
                            } else {
                                Image(systemName: "person.circle").font(.system(size: 20))
                                    
                            }
                        }
                        .buttonStyle(.plain)
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray)
//                            .font(.system(size: 20))
//                            .onTapGesture {
//                                performSearch()
//                            }
                        if(searchTypeFile)
                        {
                            
                            TextField("Search", text: $searchText)
                                .font(.system(size: 16))
                                .disableAutocorrection(true)
                                .background(Color.clear)
                                .textFieldStyle(.plain)
                                .focused($isFocused)
                                .onSubmit {
                                    performSearch()
                                    isFocused = false
                                }
                        }
                        else
                        {
                            TextField("Search by User Address", text: $searchText)
                                .font(.system(size: 16))
                                .disableAutocorrection(true)
                                .background(Color.clear)
                                .textFieldStyle(.plain)
                                .focused($isFocused)
                                .onSubmit {
                                    performSearch()
                                    isFocused = false
                                }
                        }
                        
                        if !searchText.isEmpty {
                            Button {
                                searchFilesResults = []
                                searchUsersResults = []
                                searchText = ""
                                appModel.lastSearchTerm = ""
                                
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .onHover(perform: { nv in
                        isHovering = nv
                    })
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 24).fill(Color.black.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(isFocused || isHovering ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    }
                    .padding(.horizontal, 50)
                    .frame(maxWidth: 600)
                    
                    VStack {
                       
                        if(searchTypeFile)
                        {
                            SearchResultView(files: $searchFilesResults, searchTerm: $searchText).environmentObject(appModel).transition(.opacity)
                        }
                        else
                        {
                            if(isLoading)
                            {
                                ProgressView()
                            }
                            else
                            {
                                SearchUserResultView(users: $searchUsersResults, searchTerm: $searchText).environmentObject(appModel).transition(.opacity)
                            }
                        }
                    }
                    .frame(
                        width: searchFilesResults.isEmpty && searchUsersResults.isEmpty ? 0 : nil,  // nil allows natural width when there are results
                        height: searchFilesResults.isEmpty && searchUsersResults.isEmpty  ? 0 : nil  // nil allows natural height when there are results
                    )
                    .animation(.smooth(duration: 0.75), value: searchFilesResults.count)
                    .animation(.smooth(duration: 0.75), value: searchUsersResults.count)
                    .clipped() // Ensures content doesn't overflow when frame is 0
                }
                .padding(.top,-50)
                .padding(.bottom,20)
                if(searchFilesResults.isEmpty || searchUsersResults.isEmpty)
                {
                    Spacer()
                }
            }
            .padding(.top, 20)
        }
#if os(macOS)
        .sheet(isPresented: $notFound) {
            SearchNotFoundPopup(
                isPresented: $notFound,
                searchText: $searchText,
                onDismiss: { isFocused = true }
            )
        }
#elseif os(iOS)
        .overlay(content: {
            if(notFound)
            {
                VStack{
                    SearchNotFoundPopup(
                        isPresented: $notFound,
                        searchText: $searchText,
                        onDismiss: { isFocused = true }
                    )
                }
                .padding(.top,-50)
                .frame(maxWidth: .infinity)
                .background(.white)
            }
        })
#endif
        .onAppear()
        {
            searchFilesResults = []
            searchUsersResults = []
            searchText = ""
            appModel.lastSearchTerm = ""
        }
    }
    
    func performSearch() {
        
        appModel.searchTerm = searchText
        if(appModel.lastSearchTerm != appModel.searchTerm)
        {
            appModel.lastSearchTerm = searchText
            
            if(searchTypeFile)
            {
                appModel.searchFilesWithPagination(isFirstPage: true) { results in
                    isLoading = false
                    withAnimation {
                        searchFilesResults = results
                    }
                    if(searchFilesResults.isEmpty && !searchText.isEmpty)
                    {
                        notFound = true
                    }
                }
            }
            else
            {
                isLoading = true
                appModel.searchUsersWithPagination(isFirstPage: true) { results in
                    withAnimation {
                        isLoading = false
                        searchUsersResults = results.filter { $0.id != appModel.user.id }
                    }
                    if(searchUsersResults.isEmpty && !searchText.isEmpty)
                    {
                        notFound = true
                    }
                }
            }
            
            
        }
        
    }
    
    
}

struct SearchNotFoundPopup: View {
    @Binding var isPresented: Bool
    @Binding var searchText: String
    @FocusState private var isTextFieldFocused: Bool
    var onDismiss: () -> Void
    
    var body: some View {
        VStack {
            // Hidden TextField for keyboard handling
            TextField("", text: .constant(""))
                .onSubmit {
                    isPresented = false
                    onDismiss()
                }
                .frame(width: 1, height: 1)
                .opacity(0)
                .focused($isTextFieldFocused)
                .onAppear {
#if os(macOS)
                    isTextFieldFocused = true
#endif
                }
            
            VStack(spacing: 16) {
                Text("No results found for \n\"\(searchText)\"")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal,20)
                
                Button(action: {
                    isPresented = false
                    onDismiss()
                }) {
                    Text("Try Something Else")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]),
                                         startPoint: .leading,
                                         endPoint: .trailing)
                        )
                        .cornerRadius(15)
                }
                .padding(.horizontal,50)
                .buttonStyle(PlainButtonStyle())
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
            .padding(.vertical, 32)
        }
        
    }
}

//
//  SwiftUIView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/14/24.
//
import SwiftUI

struct SearchResultView: View {
    @EnvironmentObject var appModel: AppModel
    @Binding var files: [File]
    @Binding var searchTerm: String
    // Define a fixed number of columns
    @State var columns : [GridItem] = []
    @State var resultNumber = 14
    
    var body: some View {
        GeometryReader{ geometry in
            VStack {
                if(!files.isEmpty){
                    List {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(Array(files.enumerated()), id: \.offset) { index, file in
                                if index < resultNumber {
                                    
                                    FileView(file: file).frame(maxWidth: 300).padding(5)
                                        .environmentObject(appModel)
                                }
                                else if index == resultNumber {
                                    MoreFilesButton(action: {
                                        resultNumber = resultNumber*2
                                        loadMoreResults()
                                    }).onAppear{
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            resultNumber = resultNumber*2
                                            loadMoreResults()
                                        }
                                    }
                                }
                            }
                            
                        }
                        .onChange(of: searchTerm, { oldValue, newValue in
                            resultNumber = 14
                        })
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .onChange(of: geometry.size.width) {
                withAnimation(.smooth(duration: 1)) {
                    columns = calculateGridColumns(for: geometry.size.width)
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    // Function to cap the text and add "..." if it exceeds the limit
        func displayCappedText(_ text: String, limit: Int) -> String {
            if text.count > limit {
                // Cap the text and add "..."
                return String(text.prefix(limit)) + "..."
            } else {
                // If the text is within the limit, display it as is
                return text
            }
        }
    
    func loadMoreResults() {
        
        appModel.searchFilesWithPagination(isFirstPage: false) { results in
            withAnimation {
                files.append(contentsOf: results)
            }
        }
    }
}
struct MoreFilesButton: View {
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            
            VStack(spacing: 8) {
                Image(systemName: "ellipsis.circle.fill")
//                    .font(.system(size: 32))
                    .foregroundColor(.gray)
                
                Text("Load More")
//                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: 200, maxHeight: 200)
        .aspectRatio(1, contentMode: .fit)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture(perform: action)
    }
}

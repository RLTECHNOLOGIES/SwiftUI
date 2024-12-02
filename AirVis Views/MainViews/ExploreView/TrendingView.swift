//
//  TrendingView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/15/24.
//

import SwiftUI

struct TrendingView:  View {
    @Binding var isPresented: Bool
    @EnvironmentObject var appModel: AppModel
    @State var columns: [GridItem] = []
    @State var appears: Bool = false
    @State var isLoading: Bool = false
    
    var body: some View {
        #if os(macOS)
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
//                    Text("Trending").font(.title)
                    if !appModel.trendingFiles.isEmpty {
                        if(isLoading)
                        {
                            ProgressView()
                        }
                        else
                        {
                            List {
                                Group {
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(Array(appModel.trendingFiles.enumerated()), id: \.offset) { index, file in
                                            BigFileView(file: file).environmentObject(appModel)
                                        }
                                    }
                                    
                                    .padding(10)
                                }
                                .listRowSeparator(.hidden)
                                .padding()
                                .opacity(appears ? 1 : 0)
                            }
                            .listStyle(PlainListStyle())
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.gray.opacity(0.05))
                            )
                            
                        }
                    }
                    else
                    {
                        HStack{
                            Spacer()
                            Text("Come back later for trending files.")
                            Spacer()
                        }
                    }
                }.onAppear {
                    isLoading = true
                    appModel.fetchTrendingFiles { files, error in
                        if let error = error {
                            print("Error fetching trending files: \(error)")
                        } else if let files = files {
                            appModel.trendingFiles = files
                        }
                        isLoading = false
                    }
                }
                
                
                .onAppear {
                    columns = calculateBigGridColumns(for: geometry.size.width)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.smooth(duration: 1)) {
                            appears = true
                        }
                    }
                }
                .onChange(of: geometry.size.width) { _,newWidth in
                    withAnimation(.smooth(duration: 1)) {
                        columns = calculateBigGridColumns(for: geometry.size.width)
                        //                    appears = true
                    }
                }
             
            }
        }
        
#elseif os(iOS)
        GeometryReader { geometry in
            
                VStack(spacing: 0) {
//                    Text("Trending")
//                        .font(.system(size: 24))
//                        .foregroundColor(.primary)
//                        .padding()
                    if !appModel.trendingFiles.isEmpty {
                        if(isLoading)
                        {
                            ProgressView()
                        }
                        else
                        {
                            List {
                                Group {
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(Array(appModel.trendingFiles.enumerated()), id: \.offset) { index, file in
                                            FileView(file: file).environmentObject(appModel)
                                        }
                                    }
                                }
                                .listRowSeparator(.hidden)
                                .opacity(appears ? 1 : 0)
                            }
                            .listStyle(PlainListStyle())
                        }
                       
                    }
                    else
                    {
                        HStack{
                            Spacer()
                            Text("Come back later for trending files.")
                            Spacer()
                        }
                    }
                }.onAppear {
                    isLoading = true
                    appModel.fetchTrendingFiles { files, error in
                        if let error = error {
                            print("Error fetching trending files: \(error)")
                        } else if let files = files {
                            appModel.trendingFiles = files
                        }
                        isLoading = false
                    }
                }
                .onAppear {
                    columns = calculateGridColumns(for: geometry.size.width)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.smooth(duration: 1)) {
                            appears = true
                        }
                    }
                }
                .onChange(of: geometry.size.width) { _,newWidth in
                    withAnimation(.smooth(duration: 1)) {
                        columns = calculateGridColumns(for: geometry.size.width)
                        //                    appears = true
                    }
                }
            
        }
#endif
    }
    
}

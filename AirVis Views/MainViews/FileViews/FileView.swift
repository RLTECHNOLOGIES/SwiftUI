//
//  FileView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/13/24.
//

import SwiftUI

struct FileView: View {
    var file: File
    @EnvironmentObject var appModel: AppModel
    @State private var isHovered = false
    @State private var showFullName = false
    @State private var detailedView: Bool = false
    #if os(macOS)
    @State private var image: NSImage? = nil
    #elseif os(iOS)
    @State private var image: UIImage? = nil
    #endif
//    @State private var isLoading = false
    @State private var imageOpacity: Double = 0.0 // State for image opacity
    @State var urlString = ""
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(isHovered ? 0.2 : 0.1), radius: isHovered ? 12 : 8, x: 0, y: 4)
            
            VStack(spacing: 5) {
                // Thumbnail
                
                    ZStack {
                        AsyncImageView(
                            urlString: file.thumbnailURL,
                            placeholder: Image(systemName: "exclamationmark.triangle")
                                            ).foregroundStyle(.red)
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                    }
                    .id(file.id)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 8)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // Bottom section
                
                    VStack(alignment: .center) {
                        
                        Text(showFullName ? file.fileName : displayCappedText(file.fileName, limit: 15))
                            .foregroundColor(.secondary)
                            .lineLimit(showFullName ? nil : 1)
                            .multilineTextAlignment(.center)
                            .animation(.easeInOut, value: showFullName)
                            .padding(1)
                        
                        HStack(spacing: 10){
                            HStack(spacing: 4) {
                                
                                Image(systemName: "star")
                                Text(formatNumber(file.favoritesCount)).font(.caption) // Use formatted favorite count
                            }
                            // Upvote count
                            HStack(spacing: 4) {
                                
                                Image(systemName: "heart")
                                //                    .font(.system(size: 15))
                                Text(formatNumber(file.totalUpvoteCount)) .font(.caption)
                                //                    .font(.system(size: 13, weight: .medium))
                            }
                        }
                        .frame(width: 120)
                        .foregroundColor(Color.gray.opacity(0.5))
                        //            .padding(.horizontal, 8)
                        
                        .cornerRadius(12)
                    }
                    .padding(.bottom, 5)
                
            }
            .padding(5)
        }
        .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 4)
            )
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.65), value: isHovered)
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
        .onTapGesture {
            detailedView = true
        }.frame(width: 150)
        #if os(macOS)
        .sheet(isPresented: $detailedView) {
            DetailedFileView(file: file, presented: $detailedView).environmentObject(appModel)
        }
        #elseif os(iOS)
        .fullScreenCover(isPresented: $detailedView) {
            DetailedFileView(file: file, presented: $detailedView).environmentObject(appModel)
        }

        #endif
    }
}


struct BigFileView: View {
    var file: File
    @EnvironmentObject var appModel: AppModel
    @State private var isHovered = false
    @State private var showFullName = false
    @State private var detailedView: Bool = false
#if os(macOS)
@State private var image: NSImage? = nil
#elseif os(iOS)
@State private var image: UIImage? = nil
#endif
    @State private var isLoading = false
    @State private var imageOpacity: Double = 0.0 // State for image opacity
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(isHovered ? 0.2 : 0.1), radius: isHovered ? 12 : 8, x: 0, y: 4)
            
            VStack(spacing: 5) {
                // Thumbnail
                
                    ZStack {
                        AsyncImageView(
                            urlString: file.thumbnailURL,
                                                placeholder: Image("icon")
                                            )
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 8)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // Bottom section
                
                    VStack(alignment: .center) {
                        
                        Text(showFullName ? file.fileName : displayCappedText(file.fileName, limit: 15))
                            .foregroundColor(.secondary)
                            .lineLimit(showFullName ? nil : 1)
                            .multilineTextAlignment(.center)
                            .animation(.easeInOut, value: showFullName)
                            .padding(1)
                        
                        HStack(spacing: 10){
                            HStack(spacing: 4) {
                                
                                Image(systemName: "star")
                                Text(formatNumber(file.favoritesCount)).font(.caption) // Use formatted favorite count
                            }
                            // Upvote count
                            HStack(spacing: 4) {
                                
                                Image(systemName: "heart")
                                //                    .font(.system(size: 15))
                                Text(formatNumber(file.totalUpvoteCount)) .font(.caption)
                                //                    .font(.system(size: 13, weight: .medium))
                            }
                        }
                        .frame(width: 120)
                        .foregroundColor(Color.gray.opacity(0.5))
                        //            .padding(.horizontal, 8)
                        
                        .cornerRadius(12)
                    }
                    .padding(.bottom, 5)
                
            }
            .padding(5)
        }
        .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 4)
            )
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.65), value: isHovered)
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
        .onTapGesture {
            detailedView = true
        }
        .sheet(isPresented: $detailedView) {
            DetailedFileView(file: file, presented: $detailedView).environmentObject(appModel)
        }
        .frame(width: 150)
    }
}










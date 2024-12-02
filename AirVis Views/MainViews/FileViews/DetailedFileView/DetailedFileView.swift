//
//  DetailedFileView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/13/24.
//

import SwiftUI
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct DetailedFileView: View {
    @EnvironmentObject var appModel: AppModel
    var file: File
    @State var showDetail = true
    @Environment(\.presentationMode) var presentationMode
    @State private var showPopover = false
    @Binding var presented: Bool
    @State var expandHover: Bool = false
    @State var userSheetPresented: Bool = false
    @StateObject private var keyboardObserver = KeyboardObserver()
    @State var commentExpanded: Bool = false
    
    var body: some View {
        
        #if os(macOS)
        ZStack(alignment: .top) {
            
            VStack(spacing: 5) {
                    USDZPreview(file: file, userSheetPresented: $userSheetPresented, size: 300 ).environmentObject(appModel)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    //                    .padding(.horizontal, 8)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                    //                    .padding()
                    
                    
                    
                    // Bottom section
                DetailedBottomTab(file: file, showFullName: $showDetail, commentExpanded: $commentExpanded)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 5)
                
            }
            .padding(10)
            .padding(.top, 50)
            
           
            if(userSheetPresented)
            {
                AuthorView(userID:file.uploadedBy, isPresented: $userSheetPresented).environmentObject(appModel)
                    .frame(width: 800,height: 800)
            }
            else
            {
                HStack{
                    HStack{
                        // Close button
                        Button {
                            withAnimation(.snappy(duration: 0.5))  {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                        }.buttonStyle(.plain)
                    }
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.5))  {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    Spacer()
                    Text(file.fileName)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.blue)
                        .padding(3)
                        .minimumScaleFactor(0.7)
                    Spacer()
                        HStack{
                            Button {
                                showPopover.toggle()
                                
                            } label: {
                                Image(systemName: "ellipsis.circle").font(.system(size:15)).foregroundStyle(Color.blue)
                            }
                            .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                                PopOverDetailedView(file: file, isPresented: $presented).environmentObject(appModel)
                            }
//                            .scaleEffect(expandHover ? 1.1 : 1.0)
                            .buttonStyle(.plain)
                            .onHover { expandHover in
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    self.expandHover = expandHover
                                }
                            }
                            
                        }
                }
                .padding(20)
            }
        }
        .onAppear() {
            guard let userID = appModel.dataAuth.currentUser?.uid else {
                return
            }
            if(userID == file.uploadedBy) {
                appModel.myFile = true
            } else {
                appModel.myFile = false
            }
        }
        
        
#elseif os(iOS)
ZStack{
            VStack(spacing: 0) {
                HStack{
                    HStack{
                        // Close button
                        Button {
                            withAnimation(.snappy(duration: 0.5))  {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        //                        .buttonStyle(ElevatedButtonStyle(labelColor: .gray, backgroundColor: .white, padding: 5))
                        
                        
                    }
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                    Text(file.fileName)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.blue)
                        .padding(3)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        HStack{
                            Button {
                                showPopover.toggle()
                                
                            } label: {
                                Image(systemName: "ellipsis.circle").font(.system(size:15))
                            }
                            .sheet(isPresented: $showPopover) {
                                
                                PopOverDetailedView(file: file, isPresented: $presented).environmentObject(appModel)
                                    .presentationDetents([.height(120)])
                                    .presentationDragIndicator(.hidden)
                                    .frame(maxWidth: .infinity)
                                
                            }
                            .onHover { expandHover in
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    self.expandHover = expandHover
                                }
                            }
                            
                        }
                    }
                    
                    else // POP OVER for
                    
                    {
                        HStack{
                            Button {
                                if showPopover
                                {
                                    showPopover = false
                                    showPopover = true
                                }
                                else
                                {
                                    showPopover = true
                                }
                                
                            } label: {
                                Image(systemName: "ellipsis.circle").font(.system(size:18))
                            }
                            .sheet(isPresented: $showPopover)
                            {
                                
                                
                                PopOverDetailedView(file: file, isPresented: $presented)
                                    .environmentObject(appModel)
                                    .presentationDetents([.height(120)])
                                    .presentationDragIndicator(.hidden)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            
                        }
                        
                    }
                    
                }
                .padding(.bottom,2)
                Spacer()
                VStack{
                    USDZPreview(file: file, userSheetPresented: $userSheetPresented, size: 300 ).environmentObject(appModel)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                        .scaleEffect(keyboardObserver.isKeyboardVisible ? 0.3 : 1)
                        .frame(maxWidth: keyboardObserver.isKeyboardVisible ? 90 : nil)
                        .frame(maxHeight: keyboardObserver.isKeyboardVisible ? 90 : nil)
                    // Bottom section
                    DetailedBottomTab(file: file, showFullName: $showDetail, commentExpanded: $commentExpanded)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 5)
                    
                   

                }
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $userSheetPresented, content: {
            AuthorView(userID:file.uploadedBy, isPresented: $userSheetPresented).environmentObject(appModel)
                
        })
        .padding(.horizontal,10)
        .onAppear() {
            guard let userID = appModel.dataAuth.currentUser?.uid else {
                return
            }
            if(userID == file.uploadedBy) {
                appModel.myFile = true
            } else {
                appModel.myFile = false
            }
        }
#endif
    }
    
    
}

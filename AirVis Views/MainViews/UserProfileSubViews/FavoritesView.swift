//
//  FavoritesView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/12/24.
//

import SwiftUI

struct FavoritesView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var appModel : AppModel
    @State var columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        //        GridItem(.flexible())
    ]
    @State var appears: Bool = false
    
    var body: some View {
        #if os(macOS)
        GeometryReader { geometry in
            VStack(spacing: 0){
                ZStack(alignment: .topLeading){
                    HStack{
                        Button {
                            withAnimation(.snappy(duration: 0.5))  {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                        }
                        .buttonStyle(.plain)
                        .padding()
                        .background(Color.white)
                    }.onTapGesture {
                        withAnimation(.snappy(duration: 0.5)) {
                            isPresented = false
                        }
                    }
                    VStack (spacing: 0){
                        VStack{
                            if (!appModel.favoritedFiles.isEmpty)
                            {
                                Text("Favorites")
                                    .font(.system(size: 18))
                                    .padding(.top,10)
                                    .foregroundStyle(.blue)
                                    .padding(3)
                                Divider()
                            }
                            else
                            {
                                Text("No Favorites")
                                    .font(.system(size: 18))
                                    .padding(.top,10)
                                    .foregroundStyle(.blue)
                                    .padding(3)
                                Divider()
                            }
                        }
                        if (!appModel.favoritedFiles.isEmpty)
                        {
                            List {
                                Group{
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(Array(appModel.favoritedFiles.enumerated()), id: \.offset) { index, file in
                                            FileView(file: file).environmentObject(appModel)
                                        }
                                    }
                                    .padding(10)
                                }
                                .padding()
                                .opacity(appears ? 1 : 0)
                            }
                            .background( RoundedRectangle(cornerRadius: 12)
                                .fill(.gray.opacity(0.05)))
                            
                        }
                        
                    }
                    
                    
                    
                }
                
            }
            .onAppear(perform: {
                columns = calculateGridColumns(for: geometry.size.width)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.smooth(duration: 1)) {
                        appears = true
                    }
                }
              
            })
            
            .onChange(of: geometry.size.width) { _,newWidth in
                withAnimation(.smooth(duration: 1)) {
                    columns = calculateGridColumns(for: geometry.size.width)
                    
                }
            }
            
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.02))
            )
            
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.5), lineWidth: 0.1)
            )
        }
#elseif os(iOS)
        GeometryReader { geometry in
            VStack(spacing: 0){
                        VStack{
                            HStack{
                                Button {
                                    withAnimation(.snappy(duration: 0.5))  {
                                        isPresented = false
                                    }
                                } label: {
                                    Image(systemName: "chevron.left")
                                }
                                .padding()
                                Spacer()
                                if (!appModel.favoritedFiles.isEmpty)
                                {
                                    Text("Favorites")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(.blue)
                                }
                                else
                                {
                                    Text("No Favorites")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(.blue)
                                        
                                }
                                Spacer()
                                Button {
                                    withAnimation(.snappy(duration: 0.5))  {
                                        isPresented = false
                                    }
                                } label: {
                                    Image(systemName: "arrowshape.backward.fill")
                                }
                                .opacity(0)
                                .padding()
                            }
                          
                        }
                        if (!appModel.favoritedFiles.isEmpty)
                        {
                            List {
                                Group{
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(Array(appModel.favoritedFiles.enumerated()), id: \.offset) { index, file in
                                            FileView(file: file).environmentObject(appModel)
                                        }
                                    }
                                }
                                .listRowSeparator(.hidden)
                                .padding()
                                .opacity(appears ? 1 : 0)
                            }
                            .listStyle(.plain)
                        }
            }
            .onAppear(perform: {
                columns = calculateGridColumns(for: geometry.size.width)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.smooth(duration: 1)) {
                        appears = true
                    }
                }
              
            })
            
            .onChange(of: geometry.size.width) { _,newWidth in
                withAnimation(.smooth(duration: 1)) {
                    columns = calculateGridColumns(for: geometry.size.width)
                }
            }
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.black.opacity(0.5), lineWidth: 0.1)
//            )
        }
#endif
    }
    
 
}


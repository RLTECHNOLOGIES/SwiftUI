//
//  UserSearchResultView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/21/24.
//

import SwiftUI

struct UserSearchResultRowView: View {
    let user: User
    @State var isHovering: Bool = false
    
    var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 2)
                
                HStack{
                    // Profile picture, using a placeholder if the profilePicture URL is empty
                    
#if os(macOS)
                    HStack{
                        AsyncImageView(
                                                urlString: user.profilePicture,
                                                placeholder: Image("icon")
                                            )
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        Text(user.username)
                            .font(.system(size: 14)) //
                            .foregroundColor(.blue)
                            .padding(.horizontal, 2)
                            .padding(.top, 4)
                    }.padding()
#elseif os(iOS)
                        HStack{
                        AsyncImageView(
                                                urlString: user.profilePicture,
                                                placeholder: Image("icon")
                                            )
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 1)).padding(.leading)
                        Text(user.username)
                            .font(.system(size: 18)) //
                            .foregroundColor(.blue)
                            .padding(.leading)
                            .padding(.top, 4)
                        }
                        
#endif
                       
                    
                    Spacer()
                    
                }

                
            }
//#if os(iOS)
//                    .frame(maxWidth: 400)
//#endif
            
            .scaleEffect(isHovering ? 1.0 : 0.9)
            .onHover { hovering in
                withAnimation {
                    isHovering = hovering
                }
            }
        }
}

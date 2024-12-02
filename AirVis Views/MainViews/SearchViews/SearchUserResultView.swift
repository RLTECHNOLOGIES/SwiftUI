//
//  SeachUsersView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/20/24.
//

import SwiftUI

struct SearchUserResultView: View {
    
    @EnvironmentObject var appModel: AppModel
    @Binding var users: [User]
    @Binding var searchTerm: String
    @State var resultNumber = 14
    @State var isTapEnabled: Bool = false
    @State var isAuthorPresented: Bool = false
    @State var presentingAuthor: Bool = false
    @State var userID: String = ""
    
    var body: some View {
#if os(macOS)
      List{
          ForEach(Array(users.enumerated()), id: \.offset) { index, user in
              if index < resultNumber {
                  UserSearchResultRowView(user: user).onTapGesture {
                      if isTapEnabled {
                          userID = user.id
                          isAuthorPresented = true
                      }
                  }
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
          .onAppear {
              // Enable tap gesture after 1 second
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                  isTapEnabled = true
              }
          }
          .listRowSeparator(.hidden)
      }.sheet(isPresented: $isAuthorPresented) {
          
              if(presentingAuthor)
            {
                  AuthorView(userID: userID,isPresented: $isAuthorPresented)
                      .frame(width: 800,height: 800)
                  
            }
          else
          {
              ProgressView().onAppear{
                  presentingAuthor = true
              }
          }
          
      }
#elseif os(iOS)
        List{
            ForEach(Array(users.enumerated()), id: \.offset) { index, user in
                if index < resultNumber {
                    UserSearchResultRowView(user: user).onTapGesture {
                        if isTapEnabled {
                            userID = user.id
                            isAuthorPresented = true
                        }
                    }
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
            .onAppear {
                // Enable tap gesture after 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isTapEnabled = true
                }
            }
            .listRowSeparator(.hidden)
        }
        
        .listStyle(PlainListStyle())
        .fullScreenCover(isPresented: $isAuthorPresented) {
            
                if(presentingAuthor)
              {
                    AuthorView(userID: userID,isPresented: $isAuthorPresented)
              }
            else
            {
                ProgressView().onAppear{
                    presentingAuthor = true
                }
            }
            
        }
#endif
    }
    
    
    
    func loadMoreResults() {
        
        appModel.searchUsersWithPagination(isFirstPage: false) { results in
            withAnimation {
                users.append(contentsOf: results)
            }
        }
    }
}


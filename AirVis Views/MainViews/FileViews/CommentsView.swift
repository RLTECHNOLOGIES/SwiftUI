//
//  CommentsView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/13/24.
//
import SwiftUI
import Firebase

struct CommentsView: View {
    let file: File  // File object for the comments
    @State private var comments: [Comment] = []  // List of comments to display
    @State private var newCommentText: String = ""  // Text for new comment input
    @State private var isLoading = false  // Track loading state
    @State private var isLoadingMore = false  // Track loading more state
    @EnvironmentObject var appModel: AppModel
    @Binding var commentCount: Int
    @State private var lastDocument: DocumentSnapshot? = nil  // Track last document for pagination
    @State private var hasMoreComments = true
    @State var scrollUp: Bool = false
    @State var scrollDown: Bool = false
    @State var commentsIsEmpty: Bool = true
    @FocusState private var isFocused: Bool
    @State private var isHovering: Bool = false
    
    
    var body: some View {

#if os(macOS)
        VStack {
            // Display comments
            if comments.isEmpty {
                Text("No comments yet")
                    .foregroundColor(.gray)
            } else {
                ZStack{
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 2)
                    ScrollViewReader { proxy in
                        List {
                            // Hidden anchor view at the top to scroll to
                            Text("")  // Top anchor
                                                   .frame(height: 0)
                                                   .id("TopAnchor")
                                                   .hidden()
                                                   .padding(0)
                                                   .contentMargins(0)
                            
                            ForEach(comments) { comment in
                                CommentRow(comment: comment)
                                    .listRowSeparator(.hidden)
                                    .padding(.bottom,4)
                            }
                            
                            if isLoadingMore {
                                ProgressView()
                            } else if hasMoreComments {
                                Button("Load More") {
                                    loadMoreComments()
                                }.onAppear(perform: {
                                    loadMoreComments()
                                })
                                    .padding(.leading,190)
                            }
                            Text("")  // Bottom anchor
                                .frame(height: 0)
                                .id("BottomAnchor")
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)

                        }
                        .opacity(isLoading ? 0.5 : 1)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .environment(\.defaultMinListRowHeight, 0)
                        .padding(.vertical, 1)
                        .onChange(of: scrollUp) { _,newValue in
                            if newValue {
                                DispatchQueue.main.async {
                                    withAnimation {
                                        proxy.scrollTo("TopAnchor", anchor: .top)
                                    }
                                }
                                scrollUp = false  // Reset after scrolling
                            }
                        }
                        .onChange(of: scrollDown) { _,nv in
                            if nv {
                                DispatchQueue.main.async {
                                    withAnimation {
                                        proxy.scrollTo("BottomAnchor", anchor: .bottom)
                                    }
                                }
                                scrollDown = false  // Reset after scrolling
                            }
                        }
                        
                    }
                }
               
                
            }
            
            // Comment input field
            HStack {
                TextField("Add a comment...", text: $newCommentText)
                    .font(.system(size: 15))
                    .background(Color.clear)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onSubmit {
                        if(!newCommentText.isEmpty)
                        {
                            postComments()
                        }
                    }
                if !newCommentText.isEmpty{
                    Button(action: {
                        if(!newCommentText.isEmpty)
                        {
                            postComments()
                        }
                    }) {
                        Image(systemName: "arrow.up.circle")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }.buttonStyle(PlainButtonStyle())
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
        }
        .frame(width: 500, height: 350)
        .onAppear {
            loadComments()
        }
#elseif os(iOS)
        ZStack {
            
            VStack
            {
                ProgressView()
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
           
            if(!isLoading)
            {
                VStack{
                   
                        ZStack{
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 2)
                           
                            ScrollViewReader { proxy in
                                List {
                                    // Display comments
                                    
                                    // Hidden anchor view at the top to scroll to
                                    Group{}// Top anchor
                                        .frame(maxWidth: 0.001, maxHeight: 0.001)
                                        .id("TopAnchor")
                                        .padding(0)
                                        .contentMargins(0)
                                    
                                    ForEach(comments) { comment in
                                        CommentRow(comment: comment)
                                            .padding(.top,15)
                                            .padding(.bottom,5)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets())
                                                    
                                    }
                                    
                                    if isLoadingMore {
                                        ProgressView()
                                    } else if hasMoreComments {
                                        Button("Load More") {
                                            loadMoreComments()
                                        }.listRowSeparator(.hidden)
                                        .padding(8)
                                        .frame(maxWidth: .infinity) // Makes the button take up the full width
                                        .background(Color.gray.opacity(0.2)) // Sets a gray background with some transparency
                                        .foregroundColor(.primary) // Sets the text color (optional)
                                        .cornerRadius(8) // Adds rounded corners (optional)
                                        .multilineTextAlignment(.center) // Centers the text within the button
                                        .frame(maxWidth: .infinity, alignment: .center) // Centers the button itself
                                        .onAppear{
                                            loadMoreComments()
                                            print("loading more comments")
                                        }
                                        
                                    }
                                    Group{}// BottomAnchor
                                        .frame(maxWidth: 0.001, maxHeight: 0.001)
                                        .id("BottomAnchor")
                                        .padding(0)
                                        .contentMargins(0)
                                    
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .environment(\.defaultMinListRowHeight, 0)
                                .onChange(of: scrollUp) { _,newValue in
                                    if newValue {
                                        DispatchQueue.main.async {
                                            withAnimation {
                                                proxy.scrollTo("TopAnchor", anchor: .top)
                                            }
                                        }
                                        scrollUp = false  // Reset after scrolling
                                    }
                                }
                                .onChange(of: scrollDown) { _,nv in
                                    if nv {
                                        DispatchQueue.main.async {
                                            withAnimation {
                                                proxy.scrollTo("BottomAnchor", anchor: .bottom)
                                            }
                                        }
                                        scrollDown = false  // Reset after scrolling
                                    }
                                }
                                .frame(maxWidth: 500)
                                .listStyle(.plain)
                                .padding(0)
                                
                            }
                            if commentsIsEmpty {
                                Text("No comments yet")
                                    .foregroundColor(.gray)
                            }
                        }.frame(maxWidth: 500)
                    
                    
                    // Comment input field
                    HStack {
                        TextField("Add a comment...", text: $newCommentText)
                            .font(.system(size: 16))
                            .background(Color.clear)
                            .textFieldStyle(.plain)
                            .focused($isFocused)
                            .onSubmit {
                                if(!newCommentText.isEmpty)
                                {
                                    postComments()
                                }
                            }
                        if !newCommentText.isEmpty{
                            Button(action: {
                                if(!newCommentText.isEmpty)
                                {
                                    postComments()
                                }
                            }) {
                                Image(systemName: "arrow.up.circle")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            }.buttonStyle(PlainButtonStyle())
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
                    }.onTapGesture {
                        isFocused = true
                    }
                }
                .transition(.opacity)
            }
            
          
        }
         .onAppear {
            loadComments()
        }
#endif
    }
    private func postComments() {
            
        self.scrollUp = true
            appModel.addComment(file: file, commentText: newCommentText)
    }
    // Load comments using appModel's method
    private func loadComments() {
         isLoading = true
         appModel.loadComments(for: file, limit: 5, lastDocument: nil) { comments, lastDoc, error in
             if let error = error {
                 print("Failed to load comments: \(error.localizedDescription)")
                 withAnimation(.easeInOut(duration: 0.5)) {
                     isLoading = false
                 }
             } else if let comments = comments {
                
                 self.comments = comments
                 self.lastDocument = lastDoc  // Store the last document for pagination
                 
                 // Update hasMoreComments if fewer comments than limit were returned
                             self.hasMoreComments = comments.count == 5
                 if(!comments.isEmpty)
                 {
                         commentsIsEmpty = false
                 }
                 withAnimation(.easeInOut(duration: 0.5)) {
                     isLoading = false
                 }
             }
         }
     }
    private func loadMoreComments() {
        guard hasMoreComments, let lastDoc = lastDocument else { return }
        isLoadingMore = true
        appModel.loadComments(for: file, limit: 5, lastDocument: lastDoc) { comments, lastDoc, error in
            isLoadingMore = false
            if let error = error {
                print("Failed to load more comments: \(error.localizedDescription)")
            } else if let comments = comments {
                
                self.comments.append(contentsOf: comments)
                self.lastDocument = lastDoc  // Update the last document for the next batch
                
                // Update hasMoreComments if fewer comments than limit were returned
                self.hasMoreComments = comments.count == 5
            }
        }
        scrollDown = true
    }
     
    
    
}


struct CommentRow: View {
    var comment: Comment
    @State var hasUpvoted: Bool = false  // Track upvote status
    @State var isOwner: Bool = false
    @EnvironmentObject var appModel: AppModel
    @State var likeCount: Int = 0
    @State var isHovering: Bool = false
    @State var isHoveringDelete: Bool = false
    @State var commentDeleted: Bool = false
    // Helper function to format the date
    var body: some View {
        #if os(macOS)
        if(!commentDeleted)
        {
            HStack(alignment: .top) {
                if comment.profilePicture.isEmpty {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                } else {
                    AsyncImageView(urlString: comment.profilePicture,
                                   placeholder: Image("icon"))
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1)).padding(.leading)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(comment.username)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    Text(comment.commentText)
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                        .padding(.vertical, 1)
                    
                    HStack(spacing: 3) {
                        Image(systemName: hasUpvoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .foregroundStyle(hasUpvoted ? Color.blue : Color.gray)
                            .font(.system(size: 11))
                        Text("\(likeCount)")
                            .foregroundStyle(.gray)
                    }
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isHovering = hovering
                        }
                    }
                    .scaleEffect(isHovering ? 1.1 : 1.0)
                    .padding(.horizontal, 2)
                    .padding(.top, 4)
                    
                    //                .padding()
                    .onTapGesture {
                        toggleLike()
                        hasUpvoted.toggle()
                        if(hasUpvoted)
                        {
                            
                            likeCount = likeCount + 1
                        }
                        else if(!hasUpvoted && likeCount > 0)
                        {
                            likeCount = likeCount - 1
                        }
                        
                    }
                    
                }
                Spacer()
                VStack(alignment: .trailing){
                    Text(formattedDateAndTime(from: comment.timestamp.dateValue()))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                    Spacer()
                    if comment.userID == appModel.user.id
                    {
                        Button(action: {
                            commentDeleted = true
                            appModel.deleteComment(comment) { success, error in
                                if success {
//                                    commentDeleted = true
                                    //                                print("Comment deleted successfully.")
                                } else if let error = error {
                                    print("Failed to delete comment: \(error.localizedDescription)")
                                    // Handle error, such as showing an alert to inform the user of the issue
                                }
                            }
                        }, label: {
                            Text("Delete") .font(.caption)
                        })
                        .buttonStyle(CapsuleButtonStyle(labelColor: .white, backgroundColor: .red, padding: 4))
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isHoveringDelete = hovering
                            }
                        }
                        .scaleEffect(isHoveringDelete ? 1.1 : 1.0)
                    }
                }
            }.onAppear() {
                
                checkIfUserLikedComment()
                
                likeCount = comment.likesCount
                
            }
            
            Divider()
        }
#elseif os(iOS)
        if(!commentDeleted)
        {
            HStack(alignment: .top)
            {
                if comment.profilePicture.isEmpty {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
                else
                {
                    AsyncImageView(urlString: comment.profilePicture,
                                   placeholder: Image("icon"))
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .padding(.horizontal,5)
                }
                HStack(alignment: .top)
                {
                    VStack(alignment: .leading, spacing: 0)
                    {
                        Text(comment.username)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        Text(comment.commentText)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .padding(.vertical, 1)
                        
                        Spacer()
                        HStack(spacing: 3) {
                            Image(systemName: hasUpvoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .foregroundStyle(hasUpvoted ? Color.blue : Color.gray)
                                .font(.system(size: 11))
                            Text("\(likeCount)")
                                .foregroundStyle(.gray)
                        }
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isHovering = hovering
                            }
                        }
                        .scaleEffect(isHovering ? 1.1 : 1.0)
                        .onTapGesture {
                            toggleLike()
                            withAnimation {
                                hasUpvoted.toggle()
                            }
                            if(hasUpvoted)
                            {
                                
                                likeCount = likeCount + 1
                            }
                            else if(!hasUpvoted && likeCount > 0)
                            {
                                likeCount = likeCount - 1
                            }
                            
                        }
                        
                    }
                    .frame(minHeight: 80)
                    Spacer()
                    VStack(alignment: .trailing)
                    {
                       
                        Text(formattedDateAndTime(from: comment.timestamp.dateValue()))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                        
                        if comment.userID == appModel.user.id
                        {
                            Spacer()
                            Button(action: {
                                commentDeleted = true
                                appModel.deleteComment(comment) { success, error in
                                    if success {
                                       
                                    } else if let error = error {
                                        print("Failed to delete comment: \(error.localizedDescription)")
                                        
                                    }
                                }
                            }, label: {
                                Text("Delete") .font(.caption)
                            })
                            .buttonStyle(CapsuleButtonStyle(labelColor: .white, backgroundColor: .red, padding: 4))
                            .onHover { hovering in
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    isHoveringDelete = hovering
                                }
                            }
                            .scaleEffect(isHoveringDelete ? 1.1 : 1.0)
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 2, y: 2)
                    .padding(.horizontal, -4)
                    .padding(.vertical, -7)
            )
            
            .padding(.horizontal,7)
            .padding(.vertical,2)
            .onAppear() {
                
                checkIfUserLikedComment()
                
                likeCount = comment.likesCount
                
            }
//            Divider().padding(0)
        }
#endif
    }
    private func checkIfUserLikedComment() {
            appModel.checkIfUserLikedComment(for: comment) { liked in
                self.hasUpvoted = liked
            }
        }
    private func toggleLike() {
        // Only allow a like if the user hasn't already liked this comment
        appModel.toggleLikeComment(for: comment, isLiked: hasUpvoted) { success in
            if success {
                
            }
        }
    }
}




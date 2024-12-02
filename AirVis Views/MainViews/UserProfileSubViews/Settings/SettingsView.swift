//
//  SettingsView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/12/24.
//

import SwiftUI
#if os(iOS)
import PhotosUI
#endif

struct SettingsView: View {
    @EnvironmentObject var appModel : AppModel
    @State private var showImagePicker = false
    @State private var showCropView = false
    @State private var selectedTab = 0 // Track selected tab
    @Binding var isPresented: Bool
    var body: some View {
#if os(macOS)
        VStack {
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0){
                    // Header with back button and sign out
                    HStack {
                        HStack{
                            Button {
                                withAnimation(.snappy(duration: 0.5)) {
                                    isPresented = false
                                }
                            } label: {
                                Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                            }
                            .buttonStyle(.plain)
                            .padding()
                            .background(Color.white)
                        }
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.5)) {
                                isPresented = false
                            }
                        }
                        Spacer()
                        Text("Settings")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(.blue)
                            .padding(.vertical)
                        Spacer()
                        Button {
                            withAnimation(.snappy(duration: 0.5)) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "chevron.left").foregroundStyle(Color.blue)
                        }
                        .buttonStyle(.plain)
                        .padding()
                        .opacity(0)
                        
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.02))
                    )
                    // Custom Tab View
                    Divider()
                    HStack(spacing: 0) {
                        TabButton(title: "Profile", isSelected: selectedTab == 0) {
                            withAnimation { selectedTab = 0 }
                        }
                        TabButton(title: "Help", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                    }
                    Divider()
                    
                }
                
                VStack(spacing: 20) {
                    
                    // Tab Content
                    if selectedTab == 0 {
                        ProfileTabView(
                            appModel: _appModel,
                            showImagePicker: $showImagePicker,
                            showCropView: $showCropView,
                            isPresented: $isPresented
                        )
                    } else {
                        SettingsTabView()
                    }
                }
                .padding(.top, 80)
                .padding(.horizontal, 30)
                .padding(.vertical, 50)
                .frame(width: 450, height: 500)
                .onChange(of: showImagePicker) { oldValue, newValue in
                    if newValue {
                        selectImage()
                    }
                }
                .sheet(isPresented: $showCropView) {
                    if let image = appModel.originalImage {
                        CropView(image: image) { croppedImage in
                            appModel.profileImage = croppedImage
                            showCropView = false
                        }
                    }
                }
            }
        }
        .frame(width: 450, height: 500, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.5), lineWidth: 0.3)
        )
        
#elseif os(iOS)
        
        
        VStack(spacing: 0){
            // Header with back button and sign out
            HStack {
                Button {
                    withAnimation(.snappy(duration: 0.5)) {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                //                .buttonStyle(ElevatedButtonStyle(labelColor: .gray, backgroundColor: .white, padding: 5))
                .padding()
                Spacer()
                Text("Settings")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.blue)
                    .padding(.leading, 50)
                    .padding(.vertical)
                Spacer()
                Button(action: {
                    appModel.signOut { result in
                        switch result {
                        case .success:
                            print("Sign-out successful")
                            // Navigate to login screen or perform other UI updates
                        case .failure(let error):
                            print("Sign-out failed: \(error.localizedDescription)")
                            // Show an error message to the user
                        }
                    }
                }) {
                    Text("Sign Out")
                }
                .buttonStyle(CapsuleButtonStyle(labelColor: .white, backgroundColor: .red, padding: 4))
                .padding()
            }
            // Custom Tab View
            
            
            HStack(spacing: 0) {
                TabButton(title: "Profile", isSelected: selectedTab == 0) {
                    withAnimation { selectedTab = 0 }
                }
                TabButton(title: "Help", isSelected: selectedTab == 1) {
                    withAnimation { selectedTab = 1 }
                }
            }
            
            VStack {
                // Tab Content
                if selectedTab == 0 {
                    ProfileTabView(
                        appModel: _appModel,
                        showImagePicker: $showImagePicker,
                        showCropView: $showCropView,
                        isPresented: $isPresented
                    ).padding(.top,30)
                }
                else {
                    SettingsTabView()
                        .padding(.top, 100)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { image in
                appModel.originalImage = image
                showCropView = true  // Dismiss the sheet
            }
        }
        .fullScreenCover(isPresented: $showCropView) {
            if let image = appModel.originalImage {
                ImageCropper(imageToCrop: $appModel.originalImage, croppedImage: $appModel.profileImage)
            }
        }
        
        
#endif
    }
    
#if os(macOS)
    
    private func selectImage() {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Choose Picture"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedContentTypes = [.jpeg, .heic]
        openPanel.begin { result in
            if result == .OK {
                if let url = openPanel.url {
                    if let image = NSImage(contentsOf: url) {
                        appModel.originalImage = image
                        showCropView = true
                    }
                }
            } else {
                print("Failed to choose image")
            }
            showImagePicker = false
        }
    }
#endif
    
    
    
    
    // Custom Tab Button
    struct TabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        
        var body: some View {
            
            VStack{
                Text(title)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .cornerRadius(8)
            }
            
            .background(Color.white)
            .onTapGesture {
                action()
            }
        }
    }
    
    
    // Profile Tab Content
    struct ProfileTabView: View {
        @EnvironmentObject var appModel: AppModel
        @Binding var showImagePicker: Bool
        @Binding var showCropView: Bool
        @Binding var isPresented: Bool
        @State private var debounceWorkItem: DispatchWorkItem? = nil
        @State var userAddress: String = ""
        @State var username: String = ""
        @State var bio: String = ""
        @State var userAddressAvailable: Bool = false
        @State var userAddressChecking: Bool = true
        @State var userAddressChanging: Bool = false
        var body: some View {
#if os(macOS)
            VStack(spacing: 20) {
               
                
                // Profile Image Section
                VStack(alignment: .trailing, spacing: 0){
                    if(appModel.profileImage != nil)
                    {
                        Button{
                            appModel.profileImage = nil
                        }
                        label: {
                            Image(systemName: "minus.circle")
                        }.buttonStyle(.plain).foregroundStyle(.blue)
                    }
                    if let image = appModel.profileImage {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                            .onTapGesture { showCropView = true }
                    } else {
                        Image("icon")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    }
                }
                .padding(.top, 5)
                
                
                
                
                
                
                
                
                Button("Select Picture") {
                    showImagePicker = true
                }
                .buttonStyle(ElevatedButtonStyle(labelColor: .black, backgroundColor: .white, padding: 5))
                
                // Profile Fields
                VStack(alignment: .leading) {
                    
                    VStack(alignment: .leading) {
                        TextField("Enter User Address", text: Binding(
                            get: { userAddress },
                            set: { newValue in
                                var processedValue = newValue.lowercased()
                                processedValue = processedValue.replacingOccurrences(of: " ", with: "")
                                if processedValue.count > 20 {
                                    userAddress = String(newValue.dropLast())
                                }
                                userAddress = processedValue
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: userAddress) { ov, newValue in
                            
                                if newValue.count > 20 {
                                    userAddress = String(newValue.dropLast())
                                }
                            userAddressChanging = true
                            userAddressChecking = true
                            // Cancel any existing debounce task
                            debounceWorkItem?.cancel()
                            // Create a new work item
                            let workItem = DispatchWorkItem {
                                checkAddressAvailability()
                            }
                            debounceWorkItem = workItem
                            
                            // Execute the work item after a 1-second delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
                        }
                        
                            HStack{
                                Text("\(userAddress.count)/20")
                                    .font(.caption)
                                    .foregroundColor(userAddress.count >= 20 ? .red : .gray)
                                if(userAddressChanging && appModel.userAddress != userAddress)
                                {
                                    if(userAddress.isEmpty)
                                    {
                                        Spacer()
                                        Text("*Only Lowercase")
                                            .font(.caption)
                                            .foregroundColor(userAddress.count >= 20 ? .red : .gray)
                                    }
                                    else if !userAddressChecking
                                    {
                                        Spacer()
                                        HStack(spacing: 0) {
                                            Image(systemName: userAddressAvailable ? "checkmark.circle" : "xmark.octagon")
                                                .font(.caption)
                                                .foregroundStyle(userAddressAvailable ? .green : .red)
                                            Text(userAddressAvailable ? "Available" : "Unavailable")
                                                .font(.caption)
                                                .foregroundColor(userAddress.count >= 20 ? .red : .gray)
                                        }
                                    }
                                    else
                                    {
                                        Spacer()
                                        ProgressView().scaleEffect(0.3).frame(height: 2)
                                    }
                                }
                            }
                        
                    }
                    .onAppear {
                        userAddress = appModel.userAddress
                        username = appModel.username
                        bio = appModel.bio
                    }
                    
                    
                    VStack(alignment: .leading) {
                        TextField("Enter Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                            .onChange(of: username) { _, newValue in
                                if newValue.count > 20 {
                                    username = String(newValue.dropLast())
                                }
                            }
                        
                        Text("\(username.count)/20")
                            .font(.caption)
                            .foregroundColor(username.count >= 20 ? .red : .gray)
                    }
                    
                    VStack(alignment: .leading) {
                        TextField("Enter Bio", text: $bio)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                            .onChange(of: bio) { _, newValue in
                                if newValue.count > 50 {
                                    bio = String(newValue.dropLast())
                                }
                            }
                        
                        Text("\(bio.count)/50")
                            .font(.caption)
                            .foregroundColor(bio.count >= 50 ? .red : .gray)
                    }
                }
                .frame(width: 200)
                
                Button("Save Profile") {
                    withAnimation(.bouncy(duration: 0.5)) {
                        isPresented = false
                    }
                    appModel.loadingScreen()
                    appModel.userAddress = userAddress
                    appModel.username = username
                    appModel.bio = bio
                    appModel.saveProfile { success in
                        if success {
                            userAddressChanging = false
                        } else {
                            print("Failed to save profile")
                        }
                    }
                }
                .buttonStyle(ElevatedButtonStyle(labelColor: .white, backgroundColor: .blue, padding: 6))
                .disabled(username.isEmpty || !(userAddressAvailable || userAddress == appModel.userAddress) || (userAddressChecking && userAddressChanging))
                .opacity(username.isEmpty || !(userAddressAvailable || userAddress == appModel.userAddress) || (userAddressChecking && userAddressChanging) ? 0.5 : 1)
            }
            
#elseif os(iOS)
            VStack(spacing: 20) {
                // Profile Image Section
                VStack(alignment: .trailing){
                    if(appModel.profileImage != nil)
                    {
                        Button{
                            appModel.profileImage = nil
                        }
                        label: {
                            Image(systemName: "minus.circle")
                        }
                    }
                    if let image = appModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    } else {
                        Image("icon")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    }
                }.padding(0)
                
                
                Button("Select Picture") {
                    showImagePicker = true
                }
                .buttonStyle(ElevatedButtonStyle(labelColor: .black, backgroundColor: .white, padding: 5))
                
                // Profile Fields
                VStack(alignment: .leading) {
                    
                    VStack(alignment: .leading) {
                        TextField("Enter User Address", text: Binding(
                            get: { userAddress },
                            set: { newValue in
                                var processedValue = newValue.lowercased()
                                processedValue = processedValue.replacingOccurrences(of: " ", with: "")
                                if processedValue.count > 20 {
                                    userAddress = String(newValue.dropLast())
                                }
                                userAddress = processedValue
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: userAddress) { ov, newValue in
                            
                                if newValue.count > 20 {
                                    userAddress = String(newValue.dropLast())
                                }
                            userAddressChanging = true
                            userAddressChecking = true
                            // Cancel any existing debounce task
                            debounceWorkItem?.cancel()
                            // Create a new work item
                            let workItem = DispatchWorkItem {
                                checkAddressAvailability()
                            }
                            debounceWorkItem = workItem
                            
                            // Execute the work item after a 1-second delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
                        }
                        
                            HStack{
                                Text("\(userAddress.count)/20")
                                    .font(.caption)
                                    .foregroundColor(userAddress.count >= 20 ? .red : .gray)
                                if(userAddressChanging && appModel.userAddress != userAddress)
                                {
                                    if(userAddress.isEmpty)
                                    {
                                        Spacer()
                                        Text("*Only Lowercase")
                                            .font(.caption)
                                            .foregroundColor(userAddress.count >= 20 ? .red : .gray)
                                    }
                                    else if !userAddressChecking
                                    {
                                        Spacer()
                                        HStack(spacing: 0) {
                                            Image(systemName: userAddressAvailable ? "checkmark.circle" : "xmark.octagon")
                                                .font(.caption)
                                                .foregroundStyle(userAddressAvailable ? .green : .red)
                                            Text(userAddressAvailable ? "Available" : "Unavailable")
                                                .font(.caption)
                                                .foregroundColor(userAddress.count >= 20 ? .red : .gray)
                                        }
                                    }
                                    else
                                    {
                                        Spacer()
                                        ProgressView().scaleEffect(0.75).frame(height: 5)
                                    }
                                }
                            }
                        
                    }.onAppear {
                        userAddress = appModel.userAddress
                        username = appModel.username
                        bio = appModel.bio
                    }
                    
                    
                    VStack(alignment: .leading) {
                        TextField("Enter Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                            .onChange(of: username) { _, newValue in
                                if newValue.count > 20 {
                                    username = String(newValue.dropLast())
                                }
                            }
                        
                        Text("\(username.count)/20")
                            .font(.caption)
                            .foregroundColor(username.count >= 20 ? .red : .gray)
                    }
                    
                    VStack(alignment: .leading) {
                        TextField("Enter Bio", text: $bio)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: bio) { _, newValue in
                                if newValue.count > 50 {
                                    bio = String(newValue.dropLast())
                                }
                            }
                        
                        Text("\(bio.count)/50")
                            .font(.caption)
                            .foregroundColor(bio.count >= 50 ? .red : .gray)
                    }
                }
                .frame(width: 250)
                
                Button("Save Profile") {
                    withAnimation(.bouncy(duration: 0.5)) {
                        isPresented = false
                    }
                    appModel.loadingScreen()
                    appModel.userAddress = userAddress
                    appModel.username = username
                    appModel.bio = bio
                    appModel.saveProfile { success in
                        if success {
                            userAddressChanging = false
                        } else {
                            print("Failed to save profile")
                        }
                    }
                }
                .buttonStyle(ElevatedButtonStyle(labelColor: .white, backgroundColor: .blue, padding: 6))
                .disabled(username.isEmpty ||
                          !(userAddressAvailable || userAddress == appModel.userAddress) || (userAddressChecking && userAddressChanging))
                .opacity(username.isEmpty || !(userAddressAvailable || userAddress == appModel.userAddress) || (userAddressChecking && userAddressChanging) ? 0.5 : 1)
                .padding()
            }
#endif
        }
        
        func checkAddressAvailability() {
            userAddressChecking = true
            appModel.isUserAddressAvailable(userAddress: userAddress){ success in
                    userAddressAvailable = success
                    userAddressChecking = false
            }
        }
    }
    
    // Settings Tab Content
    struct SettingsTabView: View {
        @State var isAccountManagement: Bool = false
        var body: some View {
            
#if os(macOS)
            VStack(alignment: .leading,spacing: 20) {
                Spacer()
                Group {
                    //                    SettingsRow(title: "Notifications", icon: "bell.fill")
                    
                    AccountManagement(title: "Account", icon: "person.crop.circle").onTapGesture {
                        isAccountManagement = true
                    }
                    SettingsRow(title: "Help and Support", icon: "questionmark.circle", link: "https://rocklandtechnologies.com/contact")
                    SettingsRow(title: "Terms and Conditions", icon: "info.circle.fill", link: "https://rocklandtechnologies.com/airvis")
                    SettingsRow(title: "Terms and Conditions", icon: "info.circle.fill", link: "https://rocklandtechnologies.com/airvis").opacity(0)
                }
                Spacer()
            }.sheet(isPresented: $isAccountManagement) {
                AccountManagementView()
            }
            
#elseif os(iOS)
            VStack(alignment: .leading,spacing: 20) {
                
                
                Group {
                    SettingsRow(title: "Terms and Conditions", icon: "info.circle.fill", link: "https://rocklandtechnologies.com/airvis").opacity(0)
                    AccountManagement(title: "Account", icon: "person.crop.circle").onTapGesture {
                        isAccountManagement = true
                    }
                    SettingsRow(title: "Help and Support", icon: "questionmark.circle", link: "https://rocklandtechnologies.com/contact")
                    SettingsRow(title: "Terms and Conditions", icon: "info.circle.fill", link: "https://rocklandtechnologies.com/airvis")
                    
                }
                
            }
            
            .sheet(isPresented: $isAccountManagement) {
                AccountManagementView()
            }
            
#endif
        }
    }
    
    // Settings Row Component
    struct SettingsRow: View {
        let title: String
        let icon: String
        let link: String
        
        var body: some View {
#if os(macOS)
            Button(action: {
                if let url = URL(string: link) {
                    NSWorkspace.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text(title)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .buttonStyle(.link)
#elseif os(iOS)
            Button(action: {
                if let url = URL(string: link) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text(title)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
#endif
        }
    }
    
   
}


#if os(iOS)


struct ImagePicker: UIViewControllerRepresentable {
    var onImagePicked: (UIImage) -> Void  // Callback function for handling the picked image

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Dismiss only the PHPickerViewController
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                guard let self = self, let uiImage = image as? UIImage else { return }

                DispatchQueue.main.async {
                    // Call the callback with the selected image
                    self.parent.onImagePicked(uiImage)
                }
            }
        }
    }
}

// MARK: - ImageCropper UIViewControllerRepresentable
struct ImageCropper: UIViewControllerRepresentable {
    @Binding var imageToCrop: UIImage?
    @Binding var croppedImage: UIImage?

    func makeUIViewController(context: Context) -> ImageCropperViewController {
        // Ensure the image is not nil
        guard let image = imageToCrop else {
            fatalError("Image to crop is nil")
        }
        let cropper = ImageCropperViewController(image: image)
        cropper.onCropCompleted = { image in
            croppedImage = image
        }
        return cropper
    }

    func updateUIViewController(_ uiViewController: ImageCropperViewController, context: Context) {}
}

// MARK: - ImageCropperViewController
class ImageCropperViewController: UIViewController, UIScrollViewDelegate {
    var image: UIImage?
    var onCropCompleted: ((UIImage) -> Void)?

    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    private let overlayView = UIView()
    private let headerView = UIView()
    private var cropDiameter: CGFloat = 280
    
    init(image: UIImage) {
        // Normalize the image orientation
        self.image = image.normalizedImage()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }
    
    private func setupViews() {
        guard let image = image else { return }
          
          view.backgroundColor = .black
          
          // Setup header view with white background
          headerView.backgroundColor = .white
          headerView.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(headerView)
          
          NSLayoutConstraint.activate([
              // Constrain headerView to the safe area top
              headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
              headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              headerView.heightAnchor.constraint(equalToConstant: 64) // Adjust height as needed
          ])
        
        // Configure the scroll view
        scrollView.backgroundColor = .black
        scrollView.delegate = self
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 1.0
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.clipsToBounds = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        // Add constraints for scroll view
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Configure the image view
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
        
        // Add double tap gesture for zooming
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        // Setup circular overlay
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Disable user interaction on the overlayView
        overlayView.isUserInteractionEnabled = false
        
        // Add buttons with updated styling
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Crop", for: .normal)
        doneButton.setTitleColor(.systemBlue, for: .normal)
        doneButton.addTarget(self, action: #selector(cropImage), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(doneButton)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelCrop), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(cancelButton)
        
        // Add "Cropping" label
        let croppingLabel = UILabel()
        croppingLabel.text = "Crop your image"
        croppingLabel.textColor = .black // Set to your desired color
        croppingLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        croppingLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(croppingLabel)
        
        NSLayoutConstraint.activate([
            // Constraints for "Cancel" button
            cancelButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Constraints for "Done" button
            doneButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Constraints for "Cropping" label
            croppingLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            croppingLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // Remove the custom pinch gesture recognizer if previously added
        // (Assuming you have removed it as per earlier instructions)
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let point = gesture.location(in: imageView)
            let scrollSize = scrollView.frame.size
            let size = CGSize(
                width: scrollSize.width / scrollView.maximumZoomScale,
                height: scrollSize.height / scrollView.maximumZoomScale
            )
            let origin = CGPoint(
                x: point.x - size.width / 2,
                y: point.y - size.height / 2
            )
            scrollView.zoom(to: CGRect(origin: origin, size: size), animated: true)
        }
    }
    
    private func updateLayout() {
        guard let image = image else { return }
        
        // Calculate the scale to fit the image within the scrollView while maintaining aspect ratio
        let viewSize = scrollView.bounds.size
        let widthScale = viewSize.width / image.size.width
        let heightScale = viewSize.height / image.size.height
        let minScale = min(widthScale, heightScale)
        
        // Set the content size to the scaled image size
        let scaledWidth = image.size.width * minScale
        let scaledHeight = image.size.height * minScale
        
        // Update image view frame
        imageView.frame = CGRect(
            x: (viewSize.width - scaledWidth) / 2,
            y: (viewSize.height - scaledHeight) / 2,
            width: scaledWidth,
            height: scaledHeight
        )
        cropDiameter = min(scaledWidth, scaledHeight) * scrollView.zoomScale
        // Set the minimum zoom scale to ensure the image fills the crop circle
        let cropScale = cropDiameter / min(scaledWidth, scaledHeight)
        scrollView.minimumZoomScale = max(minScale, cropScale)
        scrollView.maximumZoomScale = scrollView.minimumZoomScale * 3
        
        // Set initial zoom
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        
        // Setup the circular overlay
        setupCircularOverlay()
    }
    
    // MARK: - UIScrollViewDelegate Methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
    private func centerImage() {
        // Center the image as it's being zoomed
        let boundsSize = scrollView.bounds.size
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
    
    // MARK: - Overlay Setup
    private func setupCircularOverlay() {
           // Ensure layout is updated before calculating frames
           overlayView.layoutIfNeeded()

           // **Use the dynamic cropDiameter**
           let circleFrame = CGRect(
               x: (overlayView.bounds.width - cropDiameter) / 2,
               y: (overlayView.bounds.height - cropDiameter) / 2,
               width: cropDiameter,
               height: cropDiameter
           )

           // Create circular mask
           let path = UIBezierPath(rect: overlayView.bounds)
           let circlePath = UIBezierPath(ovalIn: circleFrame)
           path.append(circlePath)
           path.usesEvenOddFillRule = true

           let maskLayer = CAShapeLayer()
           maskLayer.path = path.cgPath
           maskLayer.fillRule = .evenOdd

           // Remove existing layers to prevent layering multiple dimming layers
           overlayView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

           // Setup the dimming layer
           let dimmingLayer = CALayer()
           dimmingLayer.frame = overlayView.bounds
           dimmingLayer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
           overlayView.layer.addSublayer(dimmingLayer)

           overlayView.layer.mask = maskLayer

           // Add border around the circle
           let borderLayer = CAShapeLayer()
           borderLayer.path = circlePath.cgPath
           borderLayer.strokeColor = UIColor.white.cgColor
           borderLayer.fillColor = UIColor.clear.cgColor
           borderLayer.lineWidth = 2
           overlayView.layer.addSublayer(borderLayer)
       }

    
    // MARK: - Cropping Logic
    @objc private func cropImage() {
        guard let image = imageView.image else { return }

        // Calculate the scale factor between the image size and the displayed image in the imageView
        let imageScale = image.size.width / imageView.bounds.width

        // Calculate the visible area of the scrollView
        let visibleRect = CGRect(
            x: scrollView.contentOffset.x,
            y: scrollView.contentOffset.y,
            width: scrollView.bounds.width,
            height: scrollView.bounds.height
        )

        // Calculate the center point of the visibleRect
        let cropCenterX = visibleRect.midX
        let cropCenterY = visibleRect.midY

        // Calculate the crop rect in the image's coordinate space
        let cropRect = CGRect(
            x: (cropCenterX - (cropDiameter / 2)) * imageScale / scrollView.zoomScale,
            y: (cropCenterY - (cropDiameter / 2)) * imageScale / scrollView.zoomScale,
            width: cropDiameter * imageScale / scrollView.zoomScale,
            height: cropDiameter * imageScale / scrollView.zoomScale
        )

        // Ensure the cropRect is within the bounds of the image
        guard let cgImage = image.cgImage,
              let croppedCGImage = cgImage.cropping(to: cropRect) else {
            print("Failed to crop image. Crop rect may be out of bounds.")
            return
        }

        // Create a circular mask for the cropped image
        UIGraphicsBeginImageContextWithOptions(CGSize(width: cropDiameter, height: cropDiameter), false, image.scale)
        let context = UIGraphicsGetCurrentContext()!

        let circularPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: cropDiameter, height: cropDiameter))
        circularPath.addClip()

        let croppedImage = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: .up)
        croppedImage.draw(in: CGRect(x: 0, y: 0, width: cropDiameter, height: cropDiameter))

        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let finalImage = finalImage {
            onCropCompleted?(finalImage)
        }

        dismiss(animated: true, completion: nil)
    }


    
    // MARK: - Cancel Action
    @objc private func cancelCrop() {
        dismiss(animated: true, completion: nil)
    }
}

#endif



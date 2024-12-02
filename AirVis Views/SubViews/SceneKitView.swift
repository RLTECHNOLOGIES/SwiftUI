//
//  SceneKit.swift
//  AirVis
//
//  Created by Arun Kurian on 11/13/24.
//

import SwiftUI
import SceneKit

#if os(macOS)
struct SceneKitView: NSViewRepresentable {
    let url: URL
    var onViewCreated: ((SCNView) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onViewCreated: onViewCreated)
    }
    
    func makeNSView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .clear

        if let scene = try? SCNScene(url: url, options: nil) {
            sceneView.scene = scene
            
            // Store initial camera transform
            if let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true) {
                context.coordinator.initialCameraTransform = cameraNode.transform
            }
        }
        
        // Perform the callback after the view is created
        DispatchQueue.main.async {
            context.coordinator.onViewCreated?(sceneView)
        }
        
        return sceneView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        
    }
    
    // Function to reset the camera to the initial position
    func resetCamera(_ sceneView: SCNView) {
        guard let cameraNode = sceneView.scene?.rootNode.childNode(withName: "camera", recursively: true),
              let initialTransform = makeCoordinator().initialCameraTransform else { return }
        
        cameraNode.transform = initialTransform
    }
    
    class Coordinator: NSObject {
        var onViewCreated: ((SCNView) -> Void)?
        var initialCameraTransform: SCNMatrix4?
        
        init(onViewCreated: ((SCNView) -> Void)?) {
            self.onViewCreated = onViewCreated
        }
    }
}
#elseif os(iOS)

struct SceneKitView: UIViewRepresentable {
    let url: URL
    var onViewCreated: ((SCNView) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onViewCreated: onViewCreated)
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .clear

        guard FileManager.default.fileExists(atPath: url.path) else {
            print("File does not exist at \(url.path)")
            return sceneView
        }
        // Attempt to load the scene, handle failure if necessary
        do {
            let scene = try SCNScene(url: url, options: nil)
            sceneView.scene = scene

            // Store initial camera transform
            if let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true) {
                context.coordinator.initialCameraTransform = cameraNode.transform
            }
        } catch {
            print("Failed to load scene from URL: \(error.localizedDescription)")
            
            // Ensure the error scene is set on the main thread
            DispatchQueue.main.async {
                sceneView.scene = createErrorScene(message: "Could not connect to the server.")
            }
        }

        DispatchQueue.main.async {
            context.coordinator.onViewCreated?(sceneView)
        }
        
        return sceneView
    }


    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // No updates needed for this view
    }
    
    // Function to reset the camera to the initial position
    func resetCamera(_ sceneView: SCNView) {
        guard let cameraNode = sceneView.scene?.rootNode.childNode(withName: "camera", recursively: true),
              let initialTransform = makeCoordinator().initialCameraTransform else { return }
        
        cameraNode.transform = initialTransform
    }
    
    class Coordinator: NSObject {
        var onViewCreated: ((SCNView) -> Void)?
        var initialCameraTransform: SCNMatrix4?
        
        init(onViewCreated: ((SCNView) -> Void)?) {
            self.onViewCreated = onViewCreated
        }
    }
    
    func createErrorScene(message: String) -> SCNScene {
        let scene = SCNScene()
        
        // Create a text node with the error message
        let textGeometry = SCNText(string: message, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red // Error message in red color
        
        // Set the font and size of the text
        textGeometry.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(x: -5, y: 0, z: 0) // Center the text
        textNode.scale = SCNVector3(0.1, 0.1, 0.1) // Scale down to fit the view

        // Create a camera to focus on the text
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15) // Position the camera to view the text
        scene.rootNode.addChildNode(cameraNode)
        
        // Add the text node to the scene
        scene.rootNode.addChildNode(textNode)
        
        return scene
    }

}

#endif

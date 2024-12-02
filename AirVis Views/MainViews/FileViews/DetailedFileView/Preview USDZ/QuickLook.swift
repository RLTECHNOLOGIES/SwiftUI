//
//  QuickLook.swift
//  AirVis
//
//  Created by Arun Kurian on 11/18/24.
//

#if os(iOS)
import QuickLook
import SwiftUI
import os


/// A SwiftUI wrapper for displaying a Quick Look view for USDZ or other files.
struct ARQuickLookView: UIViewControllerRepresentable {
    let modelFileURL: URL
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> QLPreviewControllerWrapper {
        let controller = QLPreviewControllerWrapper()
        controller.qlvc.dataSource = context.coordinator
        controller.qlvc.delegate = context.coordinator
        return controller
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func updateUIViewController(_ uiViewController: QLPreviewControllerWrapper, context: Context) {}

    /// Coordinator for managing Quick Look controller behavior
    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        let parent: ARQuickLookView

        init(parent: ARQuickLookView) {
            self.parent = parent
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.modelFileURL as QLPreviewItem
        }

        func previewControllerWillDismiss(_ controller: QLPreviewController) {
            parent.onDismiss()
        }
    }
}

/// A wrapper for QLPreviewController to manage presentation.
 class QLPreviewControllerWrapper: UIViewController {
    let qlvc = QLPreviewController()
    var qlPresented = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !qlPresented {
            present(qlvc, animated: false, completion: nil)
            qlPresented = true
        }
    }
}
#endif

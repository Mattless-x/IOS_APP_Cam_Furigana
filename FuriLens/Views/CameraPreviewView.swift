//
//  CameraPreviewView.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import SwiftUI
import AVFoundation

/// SwiftUI view that displays the camera preview using AVCaptureVideoPreviewLayer
struct CameraPreviewView: UIViewRepresentable {

    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        // Configure preview layer
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update preview layer frame when view size changes
        DispatchQueue.main.async {
            previewLayer.frame = uiView.bounds
        }
    }
}

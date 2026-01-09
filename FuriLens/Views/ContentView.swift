//
//  ContentView.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import SwiftUI

struct ContentView: View {

    @State private var viewModel = CameraViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: Camera Preview (Background)
                CameraPreviewView(previewLayer: viewModel.getPreviewLayer())
                    .ignoresSafeArea()
                    .onAppear {
                        viewModel.updateScreenSize(geometry.size)
                    }
                    .onChange(of: geometry.size) { oldSize, newSize in
                        viewModel.updateScreenSize(newSize)
                    }

                // Layer 2: Furigana Overlays
                FuriganaOverlayView(overlays: viewModel.detectedOverlays)
                    .allowsHitTesting(false) // Don't interfere with touches

                // Layer 3: Orientation Controls (Foreground)
                OrientationControlView(viewModel: viewModel)

                // Error overlay (if any)
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("⚠️ Error")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.red.opacity(0.8))
                    )
                    .padding()
                }
            }
        }
        .task {
            await viewModel.startCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
    }
}

#Preview {
    ContentView()
}

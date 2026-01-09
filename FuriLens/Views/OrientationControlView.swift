//
//  OrientationControlView.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import SwiftUI

/// Control view for switching between horizontal and vertical text orientations
struct OrientationControlView: View {

    @Bindable var viewModel: CameraViewModel

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                // Title
                Text("Text Orientation")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                // Segmented Picker
                Picker("Orientation", selection: $viewModel.currentOrientation) {
                    ForEach(TextOrientation.allCases) { orientation in
                        Text(orientation.displayName)
                            .tag(orientation)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)

                // Debug info (can be removed later)
                if !viewModel.detectedOverlays.isEmpty {
                    Text("\(viewModel.detectedOverlays.count) text region(s) detected")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.black.opacity(0.7))
                    .shadow(color: .black.opacity(0.3), radius: 10)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        OrientationControlView(viewModel: CameraViewModel())
    }
}

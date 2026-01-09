//
//  FuriganaOverlayView.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import SwiftUI

/// View that renders Furigana overlays on top of the camera feed
struct FuriganaOverlayView: View {

    let overlays: [FuriganaOverlay]

    var body: some View {
        ForEach(overlays) { overlay in
            Text(overlay.furiganaText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.red)
                .opacity(0.9)
                .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 0)
                .shadow(color: .white.opacity(0.3), radius: 1, x: 0, y: 0)
                .position(overlay.position)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        FuriganaOverlayView(overlays: [
            FuriganaOverlay(
                originalText: "日本",
                furiganaText: "にほん",
                position: CGPoint(x: 100, y: 100),
                confidence: 0.95
            ),
            FuriganaOverlay(
                originalText: "東京",
                furiganaText: "とうきょう",
                position: CGPoint(x: 200, y: 150),
                confidence: 0.92
            )
        ])
    }
}

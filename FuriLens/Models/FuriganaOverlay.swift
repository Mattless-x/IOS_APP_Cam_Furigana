//
//  FuriganaOverlay.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import Foundation
import CoreGraphics

/// Represents a Furigana overlay with its screen position
struct FuriganaOverlay: Identifiable {
    let id = UUID()
    let originalText: String
    let furiganaText: String
    let position: CGPoint // Screen coordinates (pixels, top-left origin)
    let confidence: Float

    init(originalText: String, furiganaText: String, position: CGPoint, confidence: Float = 1.0) {
        self.originalText = originalText
        self.furiganaText = furiganaText
        self.position = position
        self.confidence = confidence
    }
}

//
//  DetectedTextBox.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import Foundation
import CoreGraphics

/// Represents a detected text region from Vision OCR
struct DetectedTextBox: Identifiable {
    let id = UUID()
    let text: String
    let boundingBox: CGRect // Normalized coordinates (0.0-1.0, bottom-left origin)
    let confidence: Float

    init(text: String, boundingBox: CGRect, confidence: Float = 1.0) {
        self.text = text
        self.boundingBox = boundingBox
        self.confidence = confidence
    }
}

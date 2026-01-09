//
//  CoordinateMapper.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import Foundation
import CoreGraphics

/// Utility for converting Vision coordinates to screen coordinates
/// Vision uses normalized coordinates (0.0-1.0) with bottom-left origin
/// Screen uses pixel coordinates with top-left origin
struct CoordinateMapper {

    /// Converts Vision normalized rectangle to screen coordinates
    /// - Parameters:
    ///   - visionRect: Normalized CGRect from Vision (0.0-1.0, bottom-left origin)
    ///   - screenSize: The size of the screen/view in pixels
    /// - Returns: CGRect in screen coordinates (pixels, top-left origin)
    static func toScreen(_ visionRect: CGRect, screenSize: CGSize) -> CGRect {
        // Vision coordinates are normalized (0.0 to 1.0)
        // Vision origin is bottom-left, we need top-left

        // Convert normalized coordinates to pixel coordinates
        let x = visionRect.origin.x * screenSize.width
        let width = visionRect.size.width * screenSize.width
        let height = visionRect.size.height * screenSize.height

        // Flip Y-axis: Vision's bottom-left to Screen's top-left
        // Vision's Y=0 is at bottom, Screen's Y=0 is at top
        let y = screenSize.height - (visionRect.origin.y * screenSize.height) - height

        return CGRect(x: x, y: y, width: width, height: height)
    }

    /// Converts Vision normalized point to screen coordinates
    /// - Parameters:
    ///   - visionPoint: Normalized CGPoint from Vision (0.0-1.0, bottom-left origin)
    ///   - screenSize: The size of the screen/view in pixels
    /// - Returns: CGPoint in screen coordinates (pixels, top-left origin)
    static func toScreen(_ visionPoint: CGPoint, screenSize: CGSize) -> CGPoint {
        let x = visionPoint.x * screenSize.width

        // Flip Y-axis
        let y = screenSize.height - (visionPoint.y * screenSize.height)

        return CGPoint(x: x, y: y)
    }

    /// Calculates the position for Furigana overlay based on text orientation
    /// - Parameters:
    ///   - textBox: The detected text bounding box in screen coordinates
    ///   - orientation: Current text orientation (horizontal/vertical)
    ///   - offset: Distance from text (default 30pt for horizontal, 10pt for vertical)
    /// - Returns: CGPoint position for the Furigana text
    static func calculateFuriganaPosition(
        for textBox: CGRect,
        orientation: TextOrientation,
        horizontalOffset: CGFloat = 30,
        verticalOffset: CGFloat = 10
    ) -> CGPoint {
        switch orientation {
        case .horizontal:
            // Position above the text
            return CGPoint(
                x: textBox.minX,
                y: textBox.minY - horizontalOffset
            )

        case .vertical:
            // Position to the right of the text
            return CGPoint(
                x: textBox.maxX + verticalOffset,
                y: textBox.minY
            )
        }
    }
}

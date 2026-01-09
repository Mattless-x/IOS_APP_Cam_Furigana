//
//  TextOrientation.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import Foundation

/// Represents the text orientation mode for Japanese text detection
enum TextOrientation: String, CaseIterable, Identifiable {
    case horizontal // Books, newspapers (横書き)
    case vertical   // Manga, traditional texts (縦書き)

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .horizontal:
            return "Horizontal (Book)"
        case .vertical:
            return "Vertical (Manga)"
        }
    }
}

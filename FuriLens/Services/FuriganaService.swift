//
//  FuriganaService.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import Foundation

/// Protocol for Furigana conversion service
protocol FuriganaServiceProtocol {
    func convert(_ text: String) -> String
}

/// Service that converts Japanese Kanji to Hiragana (Furigana)
/// Uses CoreFoundation's CFStringTransform for offline conversion
class FuriganaService: FuriganaServiceProtocol {

    // MARK: - Public Methods

    /// Converts Kanji text to Hiragana reading
    /// - Parameter text: Japanese text (may contain Kanji, Kana, or mixed)
    /// - Returns: Hiragana reading of the text
    func convert(_ text: String) -> String {
        // Early return for empty strings
        guard !text.isEmpty else { return "" }

        // Skip conversion if text is already Kana or punctuation
        if isAlreadyKanaOrPunctuation(text) {
            return text
        }

        // Create mutable copy for transformation
        var mutableString = text as NSString as CFMutableString

        // Apply Kanji to Hiragana transformation
        // kCFStringTransformToLatin converts to romanized form first
        // kCFStringTransformLatinHiragana converts romanized to Hiragana
        let transforms = [
            "Any-Latin; Latin-Hiragana" as CFString
        ]

        for transform in transforms {
            if CFStringTransform(mutableString, nil, transform, false) {
                break
            }
        }

        // Clean up the result (remove spaces that may be introduced)
        let result = (mutableString as String).replacingOccurrences(of: " ", with: "")

        return result
    }

    // MARK: - Private Methods

    /// Checks if the string is already Kana or punctuation
    /// - Parameter text: Input string
    /// - Returns: true if no conversion needed
    private func isAlreadyKanaOrPunctuation(_ text: String) -> Bool {
        let kanaAndPunctuationRange = CharacterSet.hiragana
            .union(.katakana)
            .union(.punctuationCharacters)
            .union(.whitespaces)

        return text.unicodeScalars.allSatisfy { scalar in
            kanaAndPunctuationRange.contains(scalar)
        }
    }
}

// MARK: - CharacterSet Extensions

extension CharacterSet {
    /// Hiragana Unicode range: U+3040 to U+309F
    static var hiragana: CharacterSet {
        CharacterSet(charactersIn: "\u{3040}"..."\u{309F}")
    }

    /// Katakana Unicode range: U+30A0 to U+30FF
    static var katakana: CharacterSet {
        CharacterSet(charactersIn: "\u{30A0}"..."\u{30FF}")
    }
}

//
//  FuriganaServiceTests.swift
//  FuriLensTests
//
//  Created by Claude on 2026-01-09.
//

import XCTest
@testable import FuriLens

final class FuriganaServiceTests: XCTestCase {

    var service: FuriganaService!

    override func setUp() {
        super.setUp()
        service = FuriganaService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Basic Conversion Tests

    func testConvertSimpleKanji() {
        // Test: 日本 → にほん
        let result = service.convert("日本")
        XCTAssertEqual(result, "にほん", "Failed to convert 日本 to にほん")
    }

    func testConvertJapaneseLanguage() {
        // Test: 日本語 → にほんご
        let result = service.convert("日本語")
        XCTAssertEqual(result, "にほんご", "Failed to convert 日本語 to にほんご")
    }

    func testConvertComplexKanji() {
        // Test: 東京 → とうきょう
        let result = service.convert("東京")
        XCTAssertEqual(result, "とうきょう", "Failed to convert 東京 to とうきょう")
    }

    func testConvertMountainAndRiver() {
        // Test: 山 → やま, 川 → かわ
        let mountainResult = service.convert("山")
        XCTAssertEqual(mountainResult, "やま", "Failed to convert 山 to やま")

        let riverResult = service.convert("川")
        XCTAssertEqual(riverResult, "かわ", "Failed to convert 川 to かわ")
    }

    // MARK: - Already Kana Tests

    func testConvertHiraganaReturnsUnchanged() {
        // Test: ひらがな → ひらがな (should stay the same)
        let result = service.convert("ひらがな")
        XCTAssertEqual(result, "ひらがな", "Hiragana should remain unchanged")
    }

    func testConvertKatakanaReturnsUnchanged() {
        // Test: カタカナ → カタカナ (should stay the same)
        let result = service.convert("カタカナ")
        XCTAssertEqual(result, "カタカナ", "Katakana should remain unchanged")
    }

    // MARK: - Edge Cases

    func testConvertEmptyString() {
        let result = service.convert("")
        XCTAssertEqual(result, "", "Empty string should return empty string")
    }

    func testConvertPunctuation() {
        // Punctuation should remain unchanged
        let result = service.convert("。")
        XCTAssertEqual(result, "。", "Punctuation should remain unchanged")
    }

    func testConvertMixedKanjiAndKana() {
        // Test: 漢字とひらがな → かんじとひらがな
        let result = service.convert("漢字とひらがな")
        XCTAssertEqual(result, "かんじとひらがな", "Failed to convert mixed Kanji and Kana")
    }

    // MARK: - Common Words Tests

    func testConvertCommonWords() {
        let testCases: [(input: String, expected: String)] = [
            ("学校", "がっこう"),     // School
            ("先生", "せんせい"),     // Teacher
            ("本", "ほん"),          // Book
            ("漫画", "まんが"),       // Manga
            ("読む", "よむ")          // To read
        ]

        for testCase in testCases {
            let result = service.convert(testCase.input)
            XCTAssertEqual(
                result,
                testCase.expected,
                "Failed to convert \(testCase.input) to \(testCase.expected), got \(result)"
            )
        }
    }

    // MARK: - Performance Tests

    func testConversionPerformance() {
        let testString = "日本語の勉強は楽しいです"

        measure {
            _ = service.convert(testString)
        }
    }
}

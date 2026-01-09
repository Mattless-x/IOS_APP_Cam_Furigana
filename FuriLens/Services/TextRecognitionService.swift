//
//  TextRecognitionService.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import Foundation
import Vision
import CoreImage
import AVFoundation

/// Service responsible for Japanese text recognition using Vision framework
actor TextRecognitionService {

    // MARK: - Private Properties

    private var textRecognitionRequest: VNRecognizeTextRequest?

    // MARK: - Initialization

    init() {
        setupTextRecognition()
    }

    // MARK: - Public Methods

    /// Recognizes Japanese text in a sample buffer from the camera
    /// - Parameter sampleBuffer: CMSampleBuffer from AVCaptureOutput
    /// - Returns: Array of DetectedTextBox containing recognized text and bounding boxes
    func recognizeText(in sampleBuffer: CMSampleBuffer) async throws -> [DetectedTextBox] {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            throw TextRecognitionError.invalidSampleBuffer
        }

        return try await recognizeText(in: pixelBuffer)
    }

    /// Recognizes Japanese text in a pixel buffer
    /// - Parameter pixelBuffer: CVPixelBuffer containing the image
    /// - Returns: Array of DetectedTextBox containing recognized text and bounding boxes
    func recognizeText(in pixelBuffer: CVPixelBuffer) async throws -> [DetectedTextBox] {
        guard let request = textRecognitionRequest else {
            throw TextRecognitionError.requestNotInitialized
        }

        let requestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .up,
            options: [:]
        )

        return try await withCheckedThrowingContinuation { continuation in
            do {
                try requestHandler.perform([request])

                guard let results = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let detectedBoxes = results.compactMap { observation -> DetectedTextBox? in
                    // Get the top candidate text
                    guard let topCandidate = observation.topCandidates(1).first else {
                        return nil
                    }

                    // Filter out very low confidence results
                    guard topCandidate.confidence > 0.3 else {
                        return nil
                    }

                    return DetectedTextBox(
                        text: topCandidate.string,
                        boundingBox: observation.boundingBox,
                        confidence: topCandidate.confidence
                    )
                }

                continuation.resume(returning: detectedBoxes)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Private Methods

    /// Sets up the Vision text recognition request for Japanese
    private func setupTextRecognition() {
        let request = VNRecognizeTextRequest()

        // Configure for accurate Japanese text recognition
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ja-JP"]
        request.usesLanguageCorrection = true

        // Enable fast mode for real-time performance
        request.revision = VNRecognizeTextRequestRevision3

        self.textRecognitionRequest = request
    }
}

// MARK: - Error Types

enum TextRecognitionError: LocalizedError {
    case invalidSampleBuffer
    case requestNotInitialized
    case recognitionFailed

    var errorDescription: String? {
        switch self {
        case .invalidSampleBuffer:
            return "Failed to get pixel buffer from sample buffer"
        case .requestNotInitialized:
            return "Text recognition request not initialized"
        case .recognitionFailed:
            return "Text recognition failed"
        }
    }
}

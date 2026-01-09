//
//  CameraViewModel.swift
//  FuriLens
//
//  Created by Claude on 2026-01-09.
//

import Foundation
import SwiftUI
import AVFoundation

/// Central view model managing camera, text recognition, and Furigana overlay state
@MainActor
@Observable
class CameraViewModel: CameraManagerDelegate {

    // MARK: - Published State

    var currentOrientation: TextOrientation = .horizontal
    var detectedOverlays: [FuriganaOverlay] = []
    var screenSize: CGSize = .zero
    var isProcessing = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let cameraManager: CameraManager
    private let textRecognitionService: TextRecognitionService
    private let furiganaService: FuriganaService

    // MARK: - Private Properties

    private var lastProcessedTime: Date = .distantPast
    private let processingInterval: TimeInterval = 0.5 // Process every 0.5 seconds

    // MARK: - Initialization

    init(
        cameraManager: CameraManager = CameraManager(),
        textRecognitionService: TextRecognitionService = TextRecognitionService(),
        furiganaService: FuriganaService = FuriganaService()
    ) {
        self.cameraManager = cameraManager
        self.textRecognitionService = textRecognitionService
        self.furiganaService = furiganaService
        self.cameraManager.delegate = self
    }

    // MARK: - Public Methods

    /// Initializes and starts the camera
    func startCamera() async {
        do {
            try await cameraManager.setupCamera()
            cameraManager.startSession()
            errorMessage = nil
            print("✅ Camera started successfully")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Camera error: \(error.localizedDescription)")
        }
    }

    /// Stops the camera session
    func stopCamera() {
        cameraManager.stopSession()
        detectedOverlays = []
        print("🛑 Camera stopped")
    }

    /// Gets the camera preview layer
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return cameraManager.createPreviewLayer()
    }

    /// Updates the screen size (should be called when view size changes)
    func updateScreenSize(_ size: CGSize) {
        self.screenSize = size
    }

    // MARK: - CameraManagerDelegate

    nonisolated func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer) {
        Task { @MainActor in
            await processFrame(sampleBuffer)
        }
    }

    nonisolated func cameraManager(_ manager: CameraManager, didFailWithError error: CameraError) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
            print("❌ Camera error: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods

    /// Processes a camera frame with throttling
    private func processFrame(_ sampleBuffer: CMSampleBuffer) async {
        // Throttle processing to avoid overwhelming the system
        let now = Date()
        guard now.timeIntervalSince(lastProcessedTime) >= processingInterval else {
            return
        }

        guard !isProcessing else {
            return
        }

        isProcessing = true
        lastProcessedTime = now

        do {
            // Perform text recognition
            let detectedBoxes = try await textRecognitionService.recognizeText(in: sampleBuffer)

            // Log detected text to console (Phase 2 requirement)
            if !detectedBoxes.isEmpty {
                print("\n📝 Detected \(detectedBoxes.count) text region(s):")
                for (index, box) in detectedBoxes.enumerated() {
                    print("  [\(index + 1)] \(box.text) (confidence: \(String(format: "%.2f", box.confidence)))")
                }
            }

            // Process detected text into Furigana overlays
            await processDetectedText(detectedBoxes)

        } catch {
            print("⚠️ Text recognition error: \(error.localizedDescription)")
        }

        isProcessing = false
    }

    /// Converts detected text boxes into Furigana overlays
    private func processDetectedText(_ boxes: [DetectedTextBox]) async {
        guard screenSize != .zero else {
            return
        }

        // Convert each detected text box to a Furigana overlay
        let overlays = boxes.map { box -> FuriganaOverlay in
            // Convert Kanji to Hiragana
            let furiganaText = furiganaService.convert(box.text)

            // Convert Vision coordinates to screen coordinates
            let screenBox = CoordinateMapper.toScreen(box.boundingBox, screenSize: screenSize)

            // Calculate position based on current orientation
            let position = CoordinateMapper.calculateFuriganaPosition(
                for: screenBox,
                orientation: currentOrientation
            )

            return FuriganaOverlay(
                originalText: box.text,
                furiganaText: furiganaText,
                position: position,
                confidence: box.confidence
            )
        }

        // Update state
        detectedOverlays = overlays
    }
}

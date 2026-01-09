# FuriLens - iOS Prototype Implementation Plan

## Overview
FuriLens is an offline iOS camera application that detects Japanese text and overlays Furigana (Hiragana readings) in real-time. The app supports manual orientation switching between horizontal (books) and vertical (manga) text layouts.

## Core Principles
- **Offline Only**: No external API calls
- **Manual Orientation**: User-controlled toggle (no auto-detection)
- **Non-Destructive Overlay**: Furigana floats near original text
- **Modern Swift**: Swift 5.10+ with async/await
- **SwiftUI**: Pure SwiftUI implementation

---

## Project Structure

```
FuriLens/
├── App/
│   └── FuriLensApp.swift                 # App entry point
│
├── Models/
│   ├── TextOrientation.swift             # Enum: horizontal/vertical
│   ├── DetectedTextBox.swift             # Data model for OCR results
│   └── FuriganaOverlay.swift             # Model for Furigana + position
│
├── Services/
│   ├── FuriganaService.swift             # Kanji → Hiragana conversion
│   ├── CameraManager.swift               # AVFoundation camera setup
│   └── TextRecognitionService.swift      # Vision OCR pipeline
│
├── ViewModels/
│   └── CameraViewModel.swift             # Central state manager
│
├── Views/
│   ├── ContentView.swift                 # Main container view
│   ├── CameraPreviewView.swift           # Camera feed display
│   ├── FuriganaOverlayView.swift         # Renders Furigana overlays
│   └── OrientationControlView.swift      # Toggle switch UI
│
├── Utilities/
│   └── CoordinateMapper.swift            # Vision → Screen coordinate conversion
│
└── Tests/
    └── FuriganaServiceTests.swift        # Unit tests
```

---

## Architecture & Data Flow

### State Management Pattern

```
┌─────────────────────────────────────────────────────────────┐
│                      ContentView                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │          CameraViewModel (@Observable)                │  │
│  │  • currentOrientation: TextOrientation               │  │
│  │  • detectedOverlays: [FuriganaOverlay]               │  │
│  │  • screenSize: CGSize                                │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│              ┌─────────────┼─────────────┐                  │
│              ▼             ▼             ▼                   │
│    ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│    │  Camera     │  │  Furigana    │  │  Orientation    │  │
│    │  Preview    │  │  Overlay     │  │  Control        │  │
│    │  View       │  │  View        │  │  View           │  │
│    └─────────────┘  └──────────────┘  └─────────────────┘  │
│                            │                     │           │
│                     Reads overlays +      Updates            │
│                     currentOrientation    orientation        │
└─────────────────────────────────────────────────────────────┘
```

### How Toggle State Propagates to Overlay Positioning

**1. User Interaction**
```swift
// OrientationControlView.swift
Picker("Orientation", selection: $viewModel.currentOrientation) {
    Text("Horizontal (Book)").tag(TextOrientation.horizontal)
    Text("Vertical (Manga)").tag(TextOrientation.vertical)
}
```

**2. State Update**
```swift
// CameraViewModel.swift
@Observable
class CameraViewModel {
    var currentOrientation: TextOrientation = .horizontal

    // When OCR results arrive, this computes overlay positions
    func processDetectedText(_ boxes: [DetectedTextBox]) {
        detectedOverlays = boxes.map { box in
            let furigana = furiganaService.convert(box.text)
            let position = calculatePosition(for: box, orientation: currentOrientation)
            return FuriganaOverlay(text: furigana, position: position)
        }
    }

    private func calculatePosition(for box: DetectedTextBox,
                                  orientation: TextOrientation) -> CGPoint {
        let screenBox = CoordinateMapper.toScreen(box.boundingBox,
                                                   screenSize: screenSize)

        switch orientation {
        case .horizontal:
            // Above the text
            return CGPoint(x: screenBox.minX, y: screenBox.minY - 30)
        case .vertical:
            // Right of the text
            return CGPoint(x: screenBox.maxX + 10, y: screenBox.minY)
        }
    }
}
```

**3. Reactive Rendering**
```swift
// FuriganaOverlayView.swift
struct FuriganaOverlayView: View {
    let viewModel: CameraViewModel

    var body: some View {
        ForEach(viewModel.detectedOverlays) { overlay in
            Text(overlay.furiganaText)
                .position(overlay.position)  // ← Position updates automatically
                .foregroundColor(.red)
                .font(.caption)
        }
    }
}
```

**Key Insight**: When `currentOrientation` changes, `processDetectedText` recalculates positions for ALL overlays, triggering SwiftUI to re-render with new coordinates.

---

## Detailed Component Specifications

### 1. FuriganaService
**Responsibility**: Convert Kanji strings to Hiragana

```swift
protocol FuriganaServiceProtocol {
    func convert(_ text: String) -> String
}

class FuriganaService: FuriganaServiceProtocol {
    func convert(_ text: String) -> String {
        // Use CFStringTransform with kCFStringTransformLatinHiragana
        // Skip if already Kana/punctuation
    }
}
```

**Test Case**: `"日本語" → "にほんご"`

### 2. TextRecognitionService
**Responsibility**: Vision OCR pipeline

```swift
class TextRecognitionService {
    func recognizeText(in image: CMSampleBuffer) async throws -> [DetectedTextBox] {
        // Configure VNRecognizeTextRequest:
        // - recognitionLevel = .accurate
        // - recognitionLanguages = ["ja-JP"]
        // Return text + normalized bounding boxes
    }
}
```

**Output**: Array of `DetectedTextBox(text: String, boundingBox: CGRect)`

### 3. CameraManager
**Responsibility**: AVFoundation camera session

```swift
class CameraManager: NSObject {
    func startSession()
    func stopSession()
    func captureOutput(...) // Delegates frames to TextRecognitionService
}
```

### 4. CoordinateMapper
**Responsibility**: Vision (0-1, bottom-left) → Screen (pixels, top-left)

```swift
struct CoordinateMapper {
    static func toScreen(_ visionRect: CGRect, screenSize: CGSize) -> CGRect {
        // Transform coordinates
        // Flip Y-axis
    }
}
```

### 5. CameraViewModel
**Responsibility**: Central orchestrator

```swift
@Observable
class CameraViewModel {
    // State
    var currentOrientation: TextOrientation = .horizontal
    var detectedOverlays: [FuriganaOverlay] = []
    var screenSize: CGSize = .zero

    // Dependencies
    private let cameraManager: CameraManager
    private let textRecognitionService: TextRecognitionService
    private let furiganaService: FuriganaService

    // Actions
    func startCamera()
    func processFrame(_ sampleBuffer: CMSampleBuffer) async
}
```

---

## Implementation Phases

### Phase 1: Foundation ✓
- [x] Create project structure
- [x] Implement `FuriganaService`
- [x] Write unit test: `"日本" → "にほん"`
- [x] Create models: `TextOrientation`, `DetectedTextBox`, `FuriganaOverlay`

### Phase 2: Camera & OCR 📷
- [ ] Implement `CameraManager` with AVFoundation
- [ ] Implement `TextRecognitionService` with Vision
- [ ] Wire camera → OCR pipeline
- [ ] Console logging to verify Japanese text detection

### Phase 3: Interactive UI 🎨
- [ ] Implement `CameraPreviewView`
- [ ] Implement `OrientationControlView` (Picker/Segmented Control)
- [ ] Implement `FuriganaOverlayView` with conditional positioning
- [ ] Implement `CoordinateMapper`
- [ ] Wire `CameraViewModel` to all views

### Phase 4: Polish & Testing 🚀
- [ ] Test with physical book (horizontal)
- [ ] Test with manga (vertical)
- [ ] Add error handling
- [ ] Optimize performance (frame throttling)

---

## Critical Decision Points

### Toggle State Propagation (THE CORE MECHANISM)

```
User taps toggle → currentOrientation changes
                 ↓
     SwiftUI @Observable triggers update
                 ↓
     processDetectedText() recalculates positions
                 ↓
     detectedOverlays array updates
                 ↓
     FuriganaOverlayView re-renders with new positions
```

### Why This Works
1. **Single Source of Truth**: `currentOrientation` lives in `CameraViewModel`
2. **Automatic Binding**: SwiftUI's `@Observable` propagates changes
3. **Pure Functions**: `calculatePosition()` is deterministic
4. **No Manual Updates**: Views automatically react to state changes

### Coordinate System
- **Vision**: Normalized (0.0-1.0), origin = bottom-left
- **Screen**: Pixels, origin = top-left
- **Transformation**: `screenY = screenHeight - (visionY * screenHeight)`

---

## User Permissions Required

```xml
<!-- Info.plist -->
<key>NSCameraUsageDescription</key>
<string>FuriLens needs camera access to detect Japanese text</string>
```

---

## Testing Strategy

### Unit Tests
- `FuriganaService`: Kanji → Hiragana conversion
- `CoordinateMapper`: Vision → Screen coordinate math

### Integration Tests
- OCR accuracy with sample Japanese images
- Toggle state affecting overlay positions

### Manual Testing
- Physical book (horizontal text)
- Manga (vertical text)
- Mixed orientation pages

---

## Performance Considerations

1. **Frame Throttling**: Process OCR every 0.5s (not every frame)
2. **Background Processing**: Run Vision on background queue
3. **Debouncing**: Avoid recalculating overlays on rapid toggle switches

---

## Next Steps

**Awaiting approval to proceed with implementation.**

Upon approval, I will:
1. Create the Xcode project structure
2. Implement Phase 1 (Foundation + FuriganaService)
3. Run unit tests
4. Proceed to Phase 2 (Camera & OCR)
5. Implement Phase 3 (Interactive UI with Toggle)

---

## Questions for Clarification

1. **Font Size**: What size should Furigana text be? (Suggestion: `.caption` or `.caption2`)
2. **Color Scheme**: Should Furigana be red? Or configurable?
3. **Offset Values**: For positioning, should I use fixed pixels (e.g., 30pt above) or percentage-based?
4. **Throttling**: Confirm OCR processing frequency (0.5s intervals acceptable?)

---

**End of Plan**

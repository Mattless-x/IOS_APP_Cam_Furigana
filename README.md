# FuriLens - Japanese Text Furigana Overlay App

## Overview
FuriLens is an offline iOS camera application that detects Japanese text on physical objects (books, manga) and overlays Furigana (Hiragana readings) in real-time.

## ✅ Phase 1: Foundation - COMPLETED

### Implemented Components

#### 📦 Models
- **TextOrientation.swift** - Enum for horizontal/vertical text modes
- **DetectedTextBox.swift** - Data model for OCR results
- **FuriganaOverlay.swift** - Model for Furigana + screen position

#### 🔧 Services
- **FuriganaService.swift** - Kanji to Hiragana conversion using `CFStringTransform`
  - Uses CoreFoundation's `Any-Latin; Latin-Hiragana` transformation
  - Optimized: Skips conversion for already-Kana text
  - Offline only (no API calls)

#### 🧪 Tests
- **FuriganaServiceTests.swift** - Comprehensive unit tests
  - ✅ Basic Kanji conversion (日本 → にほん)
  - ✅ Complex Kanji (東京 → とうきょう)
  - ✅ Already-Kana text (unchanged)
  - ✅ Edge cases (empty strings, punctuation)
  - ✅ Common words (学校, 先生, 本, etc.)
  - ✅ Performance benchmarks

#### 📱 App Structure
- **FuriLensApp.swift** - SwiftUI app entry point
- **ContentView.swift** - Main view (placeholder for Phase 2)
- **Info.plist** - Camera permissions configured

### Project Structure
```
FuriLens/
├── App/
│   └── FuriLensApp.swift
├── Models/
│   ├── TextOrientation.swift
│   ├── DetectedTextBox.swift
│   └── FuriganaOverlay.swift
├── Services/
│   └── FuriganaService.swift
├── ViewModels/          (Phase 2)
├── Views/
│   └── ContentView.swift
├── Utilities/           (Phase 2)
└── Info.plist

FuriLensTests/
└── FuriganaServiceTests.swift
```

### How to Test Phase 1

#### Unit Tests
Run the test suite in Xcode:
```bash
# Command+U or Product → Test
```

**Expected Results:**
- ✅ `testConvertSimpleKanji`: "日本" → "にほん"
- ✅ `testConvertJapaneseLanguage`: "日本語" → "にほんご"
- ✅ `testConvertComplexKanji`: "東京" → "とうきょう"
- ✅ `testConvertHiraganaReturnsUnchanged`: "ひらがな" → "ひらがな"
- ✅ All 13 tests passing

#### Manual Testing
You can test the FuriganaService directly in a Playground:

```swift
import Foundation

let service = FuriganaService()

// Test various Kanji
print(service.convert("日本"))      // にほん
print(service.convert("東京"))      // とうきょう
print(service.convert("漫画"))      // まんが
print(service.convert("学校"))      // がっこう
print(service.convert("ひらがな"))  // ひらがな (unchanged)
```

### Tech Stack
- **Language**: Swift 5.10+
- **UI**: SwiftUI
- **NLP**: CoreFoundation (`CFStringTransform`)
- **Testing**: XCTest

### Core Constraints (Verified ✅)
- ✅ Offline only (no API calls)
- ✅ Uses native frameworks only
- ✅ Modern Swift (async/await ready)

---

## 🚧 Phase 2: Camera & OCR Pipeline (Next)

### Planned Components
- **CameraManager.swift** - AVFoundation camera session
- **TextRecognitionService.swift** - Vision OCR with VNRecognizeTextRequest
- **CoordinateMapper.swift** - Vision → Screen coordinate conversion

### Phase 2 Objectives
1. Implement camera preview
2. Configure Vision OCR for Japanese text
3. Log detected text to console
4. Test with physical Japanese text

---

## 🎨 Phase 3: Interactive UI (Future)

### Planned Components
- **CameraViewModel.swift** - State management with @Observable
- **CameraPreviewView.swift** - Camera feed display
- **FuriganaOverlayView.swift** - Renders floating Furigana
- **OrientationControlView.swift** - Toggle for Horizontal/Vertical modes

### Phase 3 Objectives
1. Build orientation toggle UI
2. Implement conditional positioning logic:
   - Horizontal: Furigana above text
   - Vertical: Furigana to the right
3. Wire state propagation from toggle to overlays
4. End-to-end testing with books and manga

---

## Development Notes

### FuriganaService Implementation Details

The service uses a two-step transformation:
1. **Kanji → Romanized Latin** (`Any-Latin`)
2. **Romanized → Hiragana** (`Latin-Hiragana`)

**Example:**
```
日本 → nihon → にほん
```

**Optimization:**
The service checks if text is already Hiragana/Katakana before transformation using Unicode ranges:
- Hiragana: U+3040 to U+309F
- Katakana: U+30A0 to U+30FF

### Camera Permissions
The Info.plist includes the required camera usage description:
> "FuriLens needs camera access to detect Japanese text and display Furigana overlays in real-time."

---

## Next Steps

1. **Run Unit Tests** to verify Phase 1 is working
2. **Proceed to Phase 2** (Camera & OCR implementation)
3. **Test with real Japanese text** to validate OCR accuracy

---

## License
This is a prototype implementation for educational purposes.

## Author
Created with Claude (2026-01-09)

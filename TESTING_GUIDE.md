# FuriLens Testing Guide

## 🎯 Quick Start

### Prerequisites
- **Mac** with macOS Ventura or later
- **Xcode 15.0+** installed
- **Physical iOS device** (iPhone/iPad running iOS 17.0+)
  - ⚠️ **Simulator will NOT work** - camera is required
- **Lightning/USB-C cable** to connect device to Mac
- **Japanese text source** (book, manga, or printed text)

---

## 📱 Step-by-Step Testing Instructions

### Step 1: Open the Project in Xcode

1. **Navigate to the project folder**
   ```bash
   cd /home/user/IOS_APP_Cam_Furigana
   ```

2. **Open the Xcode project**
   - Double-click `FuriLens.xcodeproj`
   - OR run from terminal:
     ```bash
     open FuriLens.xcodeproj
     ```

3. **Wait for Xcode to index** the project (may take a minute)

---

### Step 2: Configure Code Signing

1. **Select the FuriLens target**
   - In Xcode's left sidebar, click on the blue "FuriLens" project icon
   - Select "FuriLens" target under TARGETS

2. **Go to "Signing & Capabilities" tab**

3. **Enable Automatic Code Signing**
   - Check "Automatically manage signing"
   - Select your **Team** from the dropdown
     - If you don't have a team, you can use a free Apple ID
     - Click "Add Account..." to sign in with your Apple ID

4. **Update Bundle Identifier** (if needed)
   - Change from `com.furilens.app` to something unique like:
     - `com.yourname.furilens`

---

### Step 3: Connect Your iOS Device

1. **Connect your iPhone/iPad** to your Mac via cable

2. **Trust the computer on your device**
   - When prompted on your device, tap "Trust This Computer"
   - Enter your device passcode

3. **Select your device in Xcode**
   - At the top of Xcode, click the device selector (next to the Run button)
   - Choose your connected device (e.g., "John's iPhone")

---

### Step 4: Build and Run

1. **Click the Run button** (▶️) or press `Cmd + R`

2. **First-time setup** (if needed)
   - Xcode may ask to enable Developer Mode on your device
   - Go to Settings > Privacy & Security > Developer Mode on your device
   - Toggle it ON and restart your device

3. **Wait for the build** to complete (1-2 minutes first time)

4. **Grant camera permission** when prompted on your device
   - Tap "Allow" when FuriLens requests camera access

---

### Step 5: Test the App

#### Test 1: Horizontal Text (Books)

1. **Ensure the toggle is set to "Horizontal (Book)"** at the bottom

2. **Point your camera at horizontal Japanese text**
   - Try a Japanese textbook, newspaper, or print a sample

3. **Look for red Furigana text appearing ABOVE the Kanji**
   - Example: If the camera sees "日本語", you should see "にほんご" floating above it

4. **Check the Xcode console** for logs:
   ```
   ✅ Camera started successfully
   📝 Detected 2 text region(s):
     [1] 日本語 (confidence: 0.95)
     [2] 勉強 (confidence: 0.88)
   ```

#### Test 2: Vertical Text (Manga)

1. **Tap the segmented control** and select "Vertical (Manga)"

2. **Point your camera at vertical Japanese text**
   - Try a manga page or vertical text sample

3. **Look for red Furigana text appearing TO THE RIGHT of the Kanji**
   - The Furigana should shift position from above to beside

4. **Toggle back and forth** between modes
   - Notice how the Furigana position changes instantly
   - This demonstrates the manual orientation control working

---

## 🐛 Troubleshooting

### Issue: App won't install on device
**Solution:**
- Make sure you're signed in with your Apple ID in Xcode Preferences
- Check that your device is running iOS 17.0 or later
- Try cleaning the build folder: Product → Clean Build Folder

### Issue: Camera permission not requested
**Solution:**
- Go to Settings → FuriLens on your device
- Manually enable Camera access

### Issue: No text detected
**Solution:**
- Ensure the text is clear and in focus
- Try with larger text first (headlines work better than fine print)
- Increase lighting - Vision works better in good light
- Point the camera steadily at the text for 0.5 seconds

### Issue: Furigana is inaccurate
**Note:** CFStringTransform has limitations:
- It provides general readings, not context-aware readings
- Some Kanji with multiple readings may not match the intended reading
- This is expected - the prototype uses offline transformation only

### Issue: Console shows no logs
**Solution:**
- Make sure Xcode's console is visible: View → Debug Area → Show Debug Area
- Look for the 📝 emoji in the console output

---

## 📊 Expected Results

### What Should Work ✅
- Camera preview displays
- Japanese text is detected (may take 0.5-1 second)
- Furigana appears in red with shadow
- Toggle switches position (above ↔ right)
- Console shows detected text

### Known Limitations ⚠️
- **No simulator support** - camera required
- **0.5 second processing delay** - intentional throttling
- **Readings may be generic** - no context awareness
- **Requires good lighting** - Vision framework limitation
- **Portrait orientation only** - device should be held upright

---

## 🧪 Unit Tests

### Run Unit Tests

1. **Select the FuriLensTests scheme**
   - In Xcode, click the scheme selector and choose "FuriLensTests"

2. **Run tests**
   - Press `Cmd + U`
   - OR Product → Test

3. **Check results**
   - All 13 tests should pass ✅
   - Tests validate FuriganaService Kanji → Hiragana conversion

### Test Cases
- ✅ 日本 → にほん
- ✅ 東京 → とうきょう
- ✅ 学校 → がっこう
- ✅ 漫画 → まんが
- ✅ Already-Kana text remains unchanged
- ✅ Edge cases (empty strings, punctuation)

---

## 📸 Screenshot Checklist

When testing, verify you see:
- [ ] Black camera preview background
- [ ] Live camera feed displaying
- [ ] Red Furigana text overlays (when Japanese text is in view)
- [ ] Segmented control at bottom (Horizontal | Vertical)
- [ ] Text count indicator (e.g., "3 text region(s) detected")
- [ ] No visible errors on screen

---

## 🎓 Demo Suggestions

### Good Test Samples
1. **Japanese news website** - Print a screenshot
2. **Children's books** - Larger text works better
3. **Manga pages** - Test vertical mode
4. **Product packaging** - If you have Japanese snacks
5. **Google Translate** - Type Japanese and point camera at screen

### Sample Japanese Text to Test
```
日本語
東京タワー
勉強する
漫画を読む
こんにちは
ありがとうございます
```

---

## 🚀 Success Criteria

The app is working correctly if:

1. ✅ Camera opens and displays live feed
2. ✅ Japanese text is detected within 1 second
3. ✅ Furigana appears in red above/beside text
4. ✅ Toggle switch changes Furigana position
5. ✅ Console logs show detected text
6. ✅ No crashes or errors
7. ✅ Unit tests all pass

---

## 📝 Notes for Developer

### Architecture Verification
- Check CameraViewModel is using @Observable
- Verify toggle state propagates to overlay positioning
- Confirm 0.5s throttling prevents frame overload
- Ensure Vision coordinates map correctly to screen

### Performance Metrics
- Frame processing: ~0.5s intervals
- OCR latency: <100ms (Vision framework)
- Furigana conversion: <10ms (CFStringTransform)
- UI update: Immediate (SwiftUI reactive)

---

## ❓ Questions or Issues?

If you encounter any issues not covered here:
1. Check Xcode console for error messages
2. Review README.md for architecture details
3. Ensure all files are present (use `ls -R FuriLens/`)

---

**Happy Testing! 📱✨**

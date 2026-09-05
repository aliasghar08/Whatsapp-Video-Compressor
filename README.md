<div align="center">
  
# 🎥 PureStatus
### The Ultimate WhatsApp Video Compressor & Splitter

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

*An elegant, high-performance Flutter application designed to solve the pixelated WhatsApp status problem. Compress in HD, split flawlessly, and share instantly.*

[Features](#-key-features) • [How It Works](#-how-it-works) • [Tech Stack](#-tech-stack) • [Installation](#-installation)

</div>

---

## 🚀 Key Features

*   🎯 **Smart Video Analysis**: Analyzes your video and calculates exact original sizes before you commit to anything.
*   🎛️ **Dynamic Compression Quality**: Choose from 4 visual profiles (*Highest, Default, Medium, Low*) with clear estimates on exactly how much space you will save.
*   📊 **Before & After Metrics**: View exactly how many megabytes you saved after compression with a clean, clear UI.
*   ✂️ **Flawless Video Splitting**: Cut long videos perfectly into chunks tailored for WhatsApp Status (30s), Instagram Stories (15s), or YouTube Shorts (60s) without dropping frames.
*   🚀 **Direct WhatsApp Integration**: Bypass the clunky generic share sheet! Instantly share your compressed videos directly to **WhatsApp** or **WhatsApp Business** via a secure native Kotlin bridge.
*   🧹 **Intelligent Cache Manager**: Automatically cleans up temporary compression and split files to ensure your phone's storage stays completely bloat-free.

---

## 📱 How It Works

| Step 1: Select | Step 2: Analyze | Step 3: Compress | Step 4: Share |
| :---: | :---: | :---: | :---: |
| Pick any video directly from your device's gallery. | The app scans the file and presents you with tailored compression options. | Watch the progress bar in real-time as the hardware-accelerated engine works. | Export directly to WhatsApp or WA Business in one tap! |

---

## 🛠️ Tech Stack

This project was built with modern, scalable, and highly optimized technologies:

*   **Framework**: [Flutter](https://flutter.dev/) (Dart) for a beautiful, responsive UI.
*   **State Management**: [Riverpod](https://riverpod.dev/) for robust and scalable state handling.
*   **Video Compression**: `video_compress` leveraging native Android `MediaCodec` for hardware-accelerated compression.
*   **Video Splitting**: `ffmpeg_kit_flutter_new` using O(1) direct stream copying (`-c copy`) for lightning-fast splitting with zero re-encoding.
*   **Native Integration**: Custom Kotlin MethodChannels (`FileProvider`) for direct app-to-app sharing.

---

## 💻 Installation & Getting Started

### Prerequisites
*   Flutter SDK (Version 3.0.0 or higher)
*   Android Studio / Xcode for native compilation

### Quick Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/aliasghar08/Whatsapp-Video-Compressor.git
   ```

2. **Navigate to the project directory:**
   ```bash
   cd Whatsapp-Video-Compressor/whatsapp_video_compressor
   ```

3. **Get the dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

### 📦 Building the Release APK

To generate a production-ready, heavily optimized APK:
```bash
flutter build apk --release
```
*The resulting APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.*

---

## 🤝 Contributing

Contributions, issues, and feature requests are always welcome! 
If you have a great idea to improve the app, feel free to fork the repo and submit a pull request, or simply open an issue.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
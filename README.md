# PureStatus - WhatsApp Video Compressor & Splitter

PureStatus is a premium Flutter application designed to solve one of the most common issues with WhatsApp status updates: pixelated and heavily compressed videos. This app empowers users to pre-compress their videos in HD without losing visible quality, and flawlessly split longer videos into perfect 15, 30, or 60-second chunks for seamless status uploading.

## 🚀 Features

*   **Smart Video Analysis**: Analyzes your video and calculates exact original sizes before you commit to anything.
*   **Dynamic Compression Quality**: Choose from 4 visual profiles (Highest, Default, Medium, Low) with clear estimates on exactly how much space you will save.
*   **Before & After Metrics**: View exactly how many megabytes you saved after compression with a clean, clear UI.
*   **Video Splitting**: Cut long videos perfectly into chunks tailored for WhatsApp Status (30s), Instagram Stories (15s), or YouTube Shorts (60s) without dropping frames.
*   **Cross-Platform Ready**: Built with Flutter and Riverpod for a highly performant and responsive experience.

## 🛠️ Technology Stack

*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **State Management**: [Riverpod](https://riverpod.dev/)
*   **Video Compression Engine**: `video_compress`
*   **Video Splitting Engine**: `ffmpeg_kit_flutter_new` (Actively maintained FFmpeg fork supporting Flutter 3+ and Android V2 Embeddings)

## 📱 Screenshots & Flow
1. **Select Video**: Pick a video from your gallery.
2. **Analysis**: The app scans the file and presents you with tailored compression options.
3. **Compress**: Watch the progress bar in real-time.
4. **Results**: Review the final compressed size and export directly to WhatsApp!

## 💻 Getting Started

### Prerequisites
*   Flutter SDK (Version 3.0.0 or higher)
*   Android Studio / Xcode for native compilation

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/aliasghar08/Whatsapp-Video-Compressor.git
   ```
2. Navigate to the project directory:
   ```bash
   cd Whatsapp-Video-Compressor/whatsapp_video_compressor
   ```
3. Get the dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Building the Release APK
To generate a production-ready APK:
```bash
flutter build apk --release
```
The resulting APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
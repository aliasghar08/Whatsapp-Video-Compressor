import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class NativeService {
  static const MethodChannel _channel = MethodChannel('com.example.whatsapp_video_compressor/native');

  /// Opens the native Android gallery to select a video.
  Future<String?> openVideoGallery() async {
    try {
      final String? path = await _channel.invokeMethod('openVideoGallery');
      return path;
    } on PlatformException catch (e) {
      debugPrint("Failed to open gallery: ${e.message}");
      return null;
    }
  }

  /// Opens the native Android gallery to select a photo.
  Future<String?> openPhotoGallery() async {
    try {
      final String? path = await _channel.invokeMethod('openPhotoGallery');
      return path;
    } on PlatformException catch (e) {
      debugPrint("Failed to open gallery: ${e.message}");
      return null;
    }
  }
}

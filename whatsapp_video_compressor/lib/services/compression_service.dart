import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class CompressionService {
  static const MethodChannel _channel = MethodChannel('com.example.whatsapp_video_compressor/compression');

  /// Calls native Kotlin code to compress video for WhatsApp Status.
  Future<String?> compressVideoForWhatsApp(String inputPath) async {
    try {
      final String? outputPath = await _channel.invokeMethod('compressVideo', {
        'inputPath': inputPath,
      });
      return outputPath;
    } on PlatformException catch (e) {
      debugPrint("Compression failed: ${e.message}");
      return null;
    }
  }

  /// Calls native Kotlin code to compress a photo.
  Future<String?> compressPhotoForWhatsApp(String inputPath) async {
    try {
      final String? outputPath = await _channel.invokeMethod('compressPhoto', {
        'inputPath': inputPath,
      });
      return outputPath;
    } on PlatformException catch (e) {
      debugPrint("Photo compression failed: ${e.message}");
      return null;
    }
  }

  /// Calls native Kotlin code to split a video into 30-second chunks.
  Future<List<String>> splitVideoForStatus(String inputPath) async {
    try {
      final List<dynamic>? chunks = await _channel.invokeMethod('splitVideo', {
        'inputPath': inputPath,
        'chunkDuration': 30, // seconds
      });
      return chunks?.map((e) => e.toString()).toList() ?? [];
    } on PlatformException catch (e) {
      debugPrint("Splitting failed: ${e.message}");
      return [];
    }
  }
}


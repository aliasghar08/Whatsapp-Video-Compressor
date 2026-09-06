import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/compression_provider.dart';

class CompressionService {
  static const MethodChannel _channel = MethodChannel('com.example.whatsapp_video_compressor/compression');

  /// Compresses video using FFmpeg for precise pixel-perfect resolutions.
  Future<String?> compressVideoForWhatsApp(
    String inputPath, {
    CustomVideoQuality quality = CustomVideoQuality.hd720p,
    void Function(double)? onProgress,
    double? videoDurationMs,
  }) async {
    try {
      final dir = await getApplicationSupportDirectory(); // Save to persistent directory that works with FileProvider
      final timestampStr = DateTime.now().millisecondsSinceEpoch.toString();
      final outputPath = '${dir.path}/compressed_$timestampStr.mp4';
      
      String scaleFilter = "";
      switch (quality) {
        case CustomVideoQuality.highest1080p:
          scaleFilter = "scale=-2:1080";
          break;
        case CustomVideoQuality.hd720p:
          scaleFilter = "scale=-2:720";
          break;
        case CustomVideoQuality.sd480p:
          scaleFilter = "scale=-2:480";
          break;
      }

      // Enable progress statistics
      if (onProgress != null && videoDurationMs != null && videoDurationMs > 0) {
        FFmpegKitConfig.enableStatisticsCallback((Statistics statistics) {
          final timeInMs = statistics.getTime();
          if (timeInMs > 0) {
            double progress = (timeInMs / videoDurationMs) * 100;
            if (progress > 100) progress = 100;
            onProgress(progress);
          }
        });
      } else {
        FFmpegKitConfig.enableStatisticsCallback(null);
      }

      // -vf "$scaleFilter" : Applies scale (width auto to keep aspect ratio, height fixed)
      // -c:v libx264 -crf 28 : Standard good compression 
      // -preset superfast : Quick encoding
      // -c:a aac : Ensure audio compatibility
      final command = '-y -i "$inputPath" -vf "$scaleFilter" -c:v libx264 -crf 28 -preset superfast -c:a aac "$outputPath"';
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      // Cleanup callback
      FFmpegKitConfig.enableStatisticsCallback(null);
      
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        final logs = await session.getLogs();
        debugPrint("FFmpeg compression failed:");
        for (var log in logs) {
          debugPrint(log.getMessage());
        }
        return null;
      }
    } catch (e) {
      debugPrint("Compression failed: $e");
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

  /// Splits video using FFmpeg.
  Future<List<String>> splitVideoForStatus(String inputPath, {int chunkDurationInSeconds = 30}) async {
    try {
      final dir = await getTemporaryDirectory();
      final timestampStr = DateTime.now().millisecondsSinceEpoch.toString();
      final prefixPath = '${dir.path}/split_$timestampStr';
      final outputPattern = '${prefixPath}_%03d.mp4';
      
      final command = '-y -i "$inputPath" -c copy -map 0 -segment_time $chunkDurationInSeconds -f segment "$outputPattern"';
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        final directory = Directory(dir.path);
        final files = directory.listSync()
            .whereType<File>()
            .where((file) => file.path.startsWith(prefixPath))
            .toList();
        
        files.sort((a, b) => a.path.compareTo(b.path));
        return files.map((f) => f.path).toList();
      } else {
        final logs = await session.getLogs();
        debugPrint("FFmpeg splitting failed:");
        for (var log in logs) {
          debugPrint(log.getMessage());
        }
        return [];
      }
    } catch (e) {
      debugPrint("Splitting failed: $e");
      return [];
    }
  }

  /// Clears temporary splitting and compression cache files.
  Future<void> clearTemporaryFiles() async {
    try {
      // Clear VideoCompress cache
      await VideoCompress.deleteAllCache();
      
      // Clear old split chunks
      final dir = await getTemporaryDirectory();
      final directory = Directory(dir.path);
      if (directory.existsSync()) {
        final files = directory.listSync().whereType<File>();
        for (var file in files) {
          if (file.path.contains('split_')) {
            try {
              file.deleteSync();
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to clear temporary files: $e");
    }
  }
}


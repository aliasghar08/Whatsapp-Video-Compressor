import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CompressionService {
  static const MethodChannel _channel = MethodChannel('com.example.whatsapp_video_compressor/compression');

  /// Compresses video using video_compress plugin.
  Future<String?> compressVideoForWhatsApp(String inputPath, {VideoQuality quality = VideoQuality.DefaultQuality}) async {
    try {
      final MediaInfo? info = await VideoCompress.compressVideo(
        inputPath,
        quality: quality,
        deleteOrigin: false,
      );
      return info?.path;
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


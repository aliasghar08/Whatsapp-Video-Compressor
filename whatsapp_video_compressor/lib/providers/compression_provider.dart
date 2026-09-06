import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_compress/video_compress.dart';
import '../../services/compression_service.dart';
import '../../services/native_service.dart';
import 'history_provider.dart';

enum CustomVideoQuality {
  highest1080p,
  hd720p,
  sd480p,
}

final compressionServiceProvider = Provider<CompressionService>((ref) {
  return CompressionService();
});

final nativeServiceProvider = Provider<NativeService>((ref) {
  return NativeService();
});

class CompressionState {
  final bool isCompressing;
  final String? selectedVideoPath;
  final int? originalVideoSize;
  final double? originalVideoDuration; // in ms
  final String? compressedVideoPath;
  final int? compressedVideoSize;
  final CustomVideoQuality selectedQuality;
  
  final bool isSplitting;
  final List<String> splitVideoPaths;
  final int splitDuration;

  final String? snackbarMessage;
  final double progress;

  CompressionState({
    this.isCompressing = false,
    this.selectedVideoPath,
    this.originalVideoSize,
    this.originalVideoDuration,
    this.compressedVideoPath,
    this.compressedVideoSize,
    this.selectedQuality = CustomVideoQuality.hd720p,
    this.isSplitting = false,
    this.splitVideoPaths = const [],
    this.splitDuration = 30,
    this.snackbarMessage,
    this.progress = 0.0,
  });

  CompressionState copyWith({
    bool? isCompressing,
    String? selectedVideoPath,
    int? originalVideoSize,
    double? originalVideoDuration,
    String? compressedVideoPath,
    int? compressedVideoSize,
    CustomVideoQuality? selectedQuality,
    bool? isSplitting,
    List<String>? splitVideoPaths,
    int? splitDuration,
    String? snackbarMessage,
    double? progress,
  }) {
    return CompressionState(
      isCompressing: isCompressing ?? this.isCompressing,
      selectedVideoPath: selectedVideoPath ?? this.selectedVideoPath,
      originalVideoSize: originalVideoSize ?? this.originalVideoSize,
      originalVideoDuration: originalVideoDuration ?? this.originalVideoDuration,
      compressedVideoPath: compressedVideoPath ?? this.compressedVideoPath,
      compressedVideoSize: compressedVideoSize ?? this.compressedVideoSize,
      selectedQuality: selectedQuality ?? this.selectedQuality,
      isSplitting: isSplitting ?? this.isSplitting,
      splitVideoPaths: splitVideoPaths ?? this.splitVideoPaths,
      splitDuration: splitDuration ?? this.splitDuration,
      snackbarMessage: snackbarMessage, // Do not default to old message to allow clearing
      progress: progress ?? this.progress,
    );
  }
}

final compressionProvider = NotifierProvider<CompressionNotifier, CompressionState>(() {
  return CompressionNotifier();
});

class CompressionNotifier extends Notifier<CompressionState> {
  @override
  CompressionState build() {
    return CompressionState();
  }

  void setQuality(CustomVideoQuality quality) {
    state = state.copyWith(selectedQuality: quality);
  }
  
  void setSplitDuration(int duration) {
    state = state.copyWith(splitDuration: duration);
  }

  void clearSnackbar() {
    state = state.copyWith(snackbarMessage: null);
  }

  void clearAnalysis() {
    state = state.copyWith(
      selectedVideoPath: null,
      originalVideoSize: null,
      compressedVideoPath: null,
      compressedVideoSize: null,
    );
    ref.read(compressionServiceProvider).clearTemporaryFiles();
  }

  void loadFromHistory(String path, int originalSize, int compressedSize) {
    state = state.copyWith(
      selectedVideoPath: path,
      originalVideoSize: originalSize,
      compressedVideoPath: path,
      compressedVideoSize: compressedSize,
    );
  }

  Future<void> pickAndAnalyzeVideo() async {
    final nativeService = ref.read(nativeServiceProvider);
    
    final path = await nativeService.openVideoGallery();
    if (path != null) {
      int? fileSize;
      double? durationMs;
      try {
        final info = await VideoCompress.getMediaInfo(path);
        fileSize = info.filesize;
        durationMs = info.duration;
      } catch (e) {
        // Fallback to dart:io File size if plugin fails
        try {
          fileSize = File(path).lengthSync();
        } catch (_) {}
      }

      state = state.copyWith(
        selectedVideoPath: path,
        originalVideoSize: fileSize,
        originalVideoDuration: durationMs,
        compressedVideoPath: null,
        compressedVideoSize: null,
        splitVideoPaths: const [],
      );
    }
  }

  Future<void> startCompression() async {
    final path = state.selectedVideoPath;
    if (path == null) return;

    final compressionService = ref.read(compressionServiceProvider);
    
    state = state.copyWith(
      isCompressing: true, 
      compressedVideoPath: null,
      compressedVideoSize: null,
      progress: 0.0,
      snackbarMessage: "Compression started...",
    );
    
    try {
      final compressedPath = await compressionService.compressVideoForWhatsApp(
        path,
        quality: state.selectedQuality,
        videoDurationMs: state.originalVideoDuration,
        onProgress: (progress) {
          state = state.copyWith(progress: progress);
        },
      );
      
      if (compressedPath == null) {
        state = state.copyWith(
          isCompressing: false,
          snackbarMessage: "Error: Compression failed or returned null.",
        );
      } else {
        int? compressedSize;
        try {
          compressedSize = File(compressedPath).lengthSync();
        } catch (_) {}

        state = state.copyWith(
          isCompressing: false,
          compressedVideoPath: compressedPath,
          compressedVideoSize: compressedSize,
          snackbarMessage: "Compression successful!",
        );
        
        // Save to history
        ref.read(historyProvider.notifier).addHistoryItem(
          originalSize: state.originalVideoSize ?? 0,
          compressedSize: compressedSize ?? 0,
          path: compressedPath,
          quality: state.selectedQuality.name,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isCompressing: false,
        snackbarMessage: "Exception during compression: $e",
      );
    }
  }

  Future<void> pickAndSplitVideo() async {
    final nativeService = ref.read(nativeServiceProvider);
    final compressionService = ref.read(compressionServiceProvider);
    
    final path = await nativeService.openVideoGallery();
    if (path != null) {
      state = state.copyWith(
        isSplitting: true, 
        splitVideoPaths: const [],
        compressedVideoPath: null,
        snackbarMessage: "Splitting started...",
      );
      
      await compressionService.clearTemporaryFiles();
      
      try {
        final paths = await compressionService.splitVideoForStatus(
          path,
          chunkDurationInSeconds: state.splitDuration,
        );
        
        if (paths.isEmpty) {
          state = state.copyWith(
            isSplitting: false,
            snackbarMessage: "Error: Splitting failed or produced no chunks.",
          );
        } else {
          state = state.copyWith(
            isSplitting: false,
            splitVideoPaths: paths,
            snackbarMessage: "Splitting successful! Generated ${paths.length} chunks.",
          );
        }
      } catch (e) {
        state = state.copyWith(
          isSplitting: false,
          snackbarMessage: "Exception during splitting: $e",
        );
      }
    }
  }
}

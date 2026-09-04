import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/compression_service.dart';
import '../../services/native_service.dart';

final compressionServiceProvider = Provider<CompressionService>((ref) {
  return CompressionService();
});

final nativeServiceProvider = Provider<NativeService>((ref) {
  return NativeService();
});

class CompressionState {
  final bool isCompressing;
  final String? compressedVideoPath;

  CompressionState({
    this.isCompressing = false,
    this.compressedVideoPath,
  });

  CompressionState copyWith({
    bool? isCompressing,
    String? compressedVideoPath,
  }) {
    return CompressionState(
      isCompressing: isCompressing ?? this.isCompressing,
      compressedVideoPath: compressedVideoPath ?? this.compressedVideoPath,
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

  Future<void> pickAndCompressVideo() async {
    final nativeService = ref.read(nativeServiceProvider);
    final compressionService = ref.read(compressionServiceProvider);
    
    final path = await nativeService.openVideoGallery();
    if (path != null) {
      state = state.copyWith(isCompressing: true, compressedVideoPath: null);
      
      final compressedPath = await compressionService.compressVideoForWhatsApp(path);
      
      state = state.copyWith(
        isCompressing: false,
        compressedVideoPath: compressedPath,
      );
    }
  }
}

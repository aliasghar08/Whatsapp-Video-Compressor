import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const NativeVideoPlayer({super.key, required this.videoUrl});

  @override
  State<NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<NativeVideoPlayer> {
  MethodChannel? _channel;

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: 'native_video_player',
      creationParams: <String, dynamic>{
        'url': widget.videoUrl,
      },
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('com.example.whatsapp_video_compressor/videoPlayer_$id');
  }

  void play() {
    _channel?.invokeMethod('play');
  }

  void pause() {
    _channel?.invokeMethod('pause');
  }

  void seekTo(int milliseconds) {
    _channel?.invokeMethod('seekTo', {'position': milliseconds});
  }
}

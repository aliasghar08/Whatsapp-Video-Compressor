package com.example.whatsapp_video_compressor

import android.content.Context
import android.net.Uri
import android.view.View
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeVideoPlayerFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return NativeVideoPlayer(context, id, creationParams, messenger)
    }
}

class NativeVideoPlayer(
    context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    private val playerView: PlayerView = PlayerView(context)
    private val player: ExoPlayer = ExoPlayer.Builder(context).build()
    private val methodChannel: MethodChannel = MethodChannel(messenger, "com.example.whatsapp_video_compressor/videoPlayer_$id")

    init {
        playerView.player = player
        methodChannel.setMethodCallHandler(this)

        val url = creationParams?.get("url") as String?
        if (url != null) {
            val mediaItem = MediaItem.fromUri(Uri.parse(url))
            player.setMediaItem(mediaItem)
            player.prepare()
            player.play()
        }
    }

    override fun getView(): View {
        return playerView
    }

    override fun dispose() {
        player.release()
        methodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                player.play()
                result.success(null)
            }
            "pause" -> {
                player.pause()
                result.success(null)
            }
            "seekTo" -> {
                val position = call.argument<Int>("position")
                if (position != null) {
                    player.seekTo(position.toLong())
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}

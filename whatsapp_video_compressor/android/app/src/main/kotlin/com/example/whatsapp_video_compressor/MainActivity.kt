package com.example.whatsapp_video_compressor

import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.CountDownLatch
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.Transformer

class MainActivity: FlutterActivity() {
    private val COMPRESSION_CHANNEL = "com.example.whatsapp_video_compressor/compression"
    private val NATIVE_CHANNEL = "com.example.whatsapp_video_compressor/native"
    private val BILLING_CHANNEL = "com.example.whatsapp_video_compressor/billing"
    
    private var pendingResult: MethodChannel.Result? = null
    private val REQUEST_CODE_VIDEO = 1001
    private val REQUEST_CODE_PHOTO = 1002

    private lateinit var billingManager: BillingManager

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Clean up old temporary files
        CoroutineScope(Dispatchers.IO).launch {
            clearOldCacheFiles()
        }
        
        // Initialize Billing Manager
        val billingMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BILLING_CHANNEL)
        billingManager = BillingManager(context, this, billingMethodChannel)
        
        // Register Native Video Player
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "native_video_player",
            NativeVideoPlayerFactory(flutterEngine.dartExecutor.binaryMessenger)
        )
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COMPRESSION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {

                "compressPhoto" -> {
                    val inputPath = call.argument<String>("inputPath")
                    if (inputPath != null) {
                        CoroutineScope(Dispatchers.IO).launch {
                            val outPath = compressPhoto(inputPath)
                            withContext(Dispatchers.Main) {
                                if (outPath != null) result.success(outPath)
                                else result.error("ERROR", "Photo compression failed", null)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "inputPath is null", null)
                    }
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NATIVE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openVideoGallery" -> {
                    pendingResult = result
                    val intent = Intent(Intent.ACTION_GET_CONTENT)
                    intent.type = "video/*"
                    startActivityForResult(intent, REQUEST_CODE_VIDEO)
                }
                "openPhotoGallery" -> {
                    pendingResult = result
                    val intent = Intent(Intent.ACTION_GET_CONTENT)
                    intent.type = "image/*"
                    startActivityForResult(intent, REQUEST_CODE_PHOTO)
                }
                "shareVideoToWhatsApp" -> {
                    val videoPath = call.argument<String>("videoPath")
                    val isBusiness = call.argument<Boolean>("isBusiness") ?: false
                    
                    if (videoPath != null) {
                        try {
                            val file = File(videoPath)
                            val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
                            
                            val intent = Intent(Intent.ACTION_SEND).apply {
                                type = "video/*"
                                putExtra(Intent.EXTRA_STREAM, uri)
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                setPackage(if (isBusiness) "com.whatsapp.w4b" else "com.whatsapp")
                            }
                            
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            e.printStackTrace()
                            result.error("SHARE_ERROR", "Could not share video: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "videoPath is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == RESULT_OK && data != null && data.data != null) {
            val uri = data.data!!
            CoroutineScope(Dispatchers.IO).launch {
                val filePath = copyUriToTempFile(uri)
                withContext(Dispatchers.Main) {
                    if (filePath != null) {
                        pendingResult?.success(filePath)
                    } else {
                        pendingResult?.error("ERROR", "Failed to copy file", null)
                    }
                    pendingResult = null
                }
            }
        } else {
            pendingResult?.success(null)
            pendingResult = null
        }
    }

    private fun copyUriToTempFile(uri: Uri): String? {
        try {
            val cursor = contentResolver.query(uri, null, null, null, null)
            val nameIndex = cursor?.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            var fileName = "temp_file_${System.currentTimeMillis()}"
            if (cursor != null && cursor.moveToFirst() && nameIndex != null) {
                fileName = cursor.getString(nameIndex)
                cursor.close()
            }
            
            val tempFile = File(context.cacheDir, fileName)
            val inputStream = contentResolver.openInputStream(uri)
            val outputStream = FileOutputStream(tempFile)
            
            inputStream?.copyTo(outputStream)
            inputStream?.close()
            outputStream.close()
            
            return tempFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun compressPhoto(inputPath: String): String? {
        try {
            val bitmap = android.graphics.BitmapFactory.decodeFile(inputPath) ?: return null
            val outputDir = context.cacheDir
            val outputFile = File(outputDir, "compressed_photo_${System.currentTimeMillis()}.jpg")
            val outputStream = java.io.FileOutputStream(outputFile)
            
            bitmap.compress(android.graphics.Bitmap.CompressFormat.JPEG, 80, outputStream)
            outputStream.flush()
            outputStream.close()
            
            return outputFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun clearOldCacheFiles() {
        try {
            val cacheDir = context.cacheDir
            if (cacheDir != null && cacheDir.exists() && cacheDir.isDirectory) {
                val oneHourAgo = System.currentTimeMillis() - (60 * 60 * 1000)
                val files = cacheDir.listFiles()
                files?.forEach { file ->
                    if (file.isFile && (file.name.startsWith("temp_file_") || file.name.startsWith("compressed_photo_") || file.name.startsWith("split_"))) {
                        if (file.lastModified() < oneHourAgo) {
                            file.delete()
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

}

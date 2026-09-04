import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class BillingService {
  static const MethodChannel _channel = MethodChannel('com.example.whatsapp_video_compressor/billing');

  /// Requests to purchase the premium subscription.
  Future<void> purchasePremium() async {
    try {
      await _channel.invokeMethod('purchasePremium');
    } on PlatformException catch (e) {
      debugPrint("Failed to purchase premium: ${e.message}");
    }
  }

  /// Checks if the user is currently a premium user based on Google Play caches.
  Future<bool> isPremium() async {
    try {
      final bool? result = await _channel.invokeMethod('isPremium');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to check premium status: ${e.message}");
      return false;
    }
  }

  /// Listen to successful purchases streamed from native.
  void setPurchaseListener(void Function() onPurchaseSuccessful) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPurchaseSuccessful') {
        onPurchaseSuccessful();
      }
    });
  }
}

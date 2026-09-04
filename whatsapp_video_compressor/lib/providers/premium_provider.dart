import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/billing_service.dart';

final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService();
});

final premiumProvider = NotifierProvider<PremiumNotifier, bool>(() {
  return PremiumNotifier();
});

class PremiumNotifier extends Notifier<bool> {
  @override
  bool build() {
    checkPremium();
    return false;
  }

  Future<void> checkPremium() async {
    final billingService = ref.read(billingServiceProvider);
    final isPremium = await billingService.isPremium();
    state = isPremium;
  }

  Future<void> purchasePremium() async {
    final billingService = ref.read(billingServiceProvider);
    await billingService.purchasePremium();
    await checkPremium();
  }
}

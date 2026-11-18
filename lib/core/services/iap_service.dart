import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../config/app_config.dart';

/// Handles Apple StoreKit & Google Play Billing non-consumable purchase and restore
/// for [AppConfig.adFreeProductId].
class IapService {
  IapService._();
  static final IapService instance = IapService._();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _adFreeProduct;
  bool _isStoreAvailable = false;
  Future<void> Function()? _onAdFreeEntitlementGranted;

  ProductDetails? get adFreeProduct => _adFreeProduct;
  bool get isStoreAvailable => _isStoreAvailable;

  /// Formatted localized price from Apple StoreKit / Google Play (or fallback label)
  String? get localizedPrice => _adFreeProduct?.price;

  Future<void> initialize({
    required Future<void> Function() onAdFreeEntitlementGranted,
  }) async {
    _onAdFreeEntitlementGranted = onAdFreeEntitlementGranted;
    try {
      final iap = InAppPurchase.instance;
      _isStoreAvailable = await iap.isAvailable();
      if (!_isStoreAvailable) return;

      _subscription ??= iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (Object e) => debugPrint('IAP stream error: $e'),
      );

      final response = await iap.queryProductDetails({AppConfig.adFreeProductId});
      if (response.productDetails.isNotEmpty) {
        _adFreeProduct = response.productDetails.first;
      }
    } catch (e) {
      debugPrint('IAP initialization skipped/unavailable on this platform: $e');
      _isStoreAvailable = false;
    }
  }

  Future<bool> buyAdFree() async {
    try {
      if (_isStoreAvailable && _adFreeProduct != null) {
        final param = PurchaseParam(productDetails: _adFreeProduct!);
        return await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
      }
      // In debug/testing mode when StoreKit product isn't configured in App Store Connect yet
      if (kDebugMode) {
        await _onAdFreeEntitlementGranted?.call();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('buyAdFree error: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      if (_isStoreAvailable) {
        await InAppPurchase.instance.restorePurchases();
        return true;
      }
      if (kDebugMode) {
        await _onAdFreeEntitlementGranted?.call();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('restorePurchases error: $e');
      return false;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      if (purchase.productID == AppConfig.adFreeProductId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          await _onAdFreeEntitlementGranted?.call();
        }
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

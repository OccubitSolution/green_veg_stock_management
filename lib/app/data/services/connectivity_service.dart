import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends GetxService {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final RxBool isOnline = true.obs;
  final RxBool isInitialized = false.obs;

  Future<ConnectivityService> init() async {
    if (isInitialized.value) return this;

    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    _connectivity.onConnectivityChanged.listen(_updateStatus);
    isInitialized.value = true;
    debugPrint('✅ ConnectivityService initialized');
    return this;
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasOnline = isOnline.value;
    isOnline.value = results.isNotEmpty && 
        !results.contains(ConnectivityResult.none);
    
    if (wasOnline != isOnline.value) {
      if (isOnline.value) {
        debugPrint('📶 Back online');
        _onReconnect();
      } else {
        debugPrint('📴 Went offline');
      }
    }
  }

  void _onReconnect() {
    Get.rawSnackbar(
      message: 'Back online',
      duration: const Duration(seconds: 2),
    );
  }

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    isOnline.value = results.isNotEmpty && 
        !results.contains(ConnectivityResult.none);
    return isOnline.value;
  }
}

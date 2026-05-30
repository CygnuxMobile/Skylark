import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  bool _isDialogShowing = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });

    // Check initial status after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialStatus();
    });
  }

  Future<void> _checkInitialStatus() async {
    // Wait for the app to be fully ready
    await Future.delayed(const Duration(milliseconds: 1000));
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    debugPrint("Connectivity Status: $results");

    bool hasNoInternet = results.contains(ConnectivityResult.none) || results.isEmpty;

    if (hasNoInternet) {
      if (!_isDialogShowing) {
        _showNoInternetDialog();
      }
    } else {
      if (_isDialogShowing) {
        _closeDialog();
      }
    }
  }

  void _showNoInternetDialog() {
    _isDialogShowing = true;
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('No Internet'),
            ],
          ),
          content: const Text(
            'Please check your internet connection and try again.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final results = await _connectivity.checkConnectivity();
                if (!results.contains(ConnectivityResult.none) && results.isNotEmpty) {
                  _closeDialog();
                }
              },
              child: const Text('RETRY', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _closeDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    _isDialogShowing = false;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<bool> checkInternet() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none) && connectivityResult.isNotEmpty;
  }
}

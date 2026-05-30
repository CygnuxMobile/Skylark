import 'package:get/get.dart';
import 'package:skylark/app/data/services/storage_service.dart';
import 'package:skylark/app/routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onReady() {
    super.onReady();
    _handleNavigation();
  }

  void _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (_storageService.isLoggedIn()) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}

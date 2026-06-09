import 'package:get/get.dart';
import 'manifest_controller.dart';

class ManifestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManifestController>(() => ManifestController());
  }
}

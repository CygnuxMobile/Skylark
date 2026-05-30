import 'package:get/get.dart';
import 'drs_controller.dart';

class DrsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DrsController>(() => DrsController());
  }
}

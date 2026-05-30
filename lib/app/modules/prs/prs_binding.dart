import 'package:get/get.dart';
import 'prs_controller.dart';

class PrsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrsController>(() => PrsController());
  }
}

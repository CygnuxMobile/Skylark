import 'package:get/get.dart';
import 'drs_closure_controller.dart';

class DrsClosureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DrsClosureController>(() => DrsClosureController());
  }
}

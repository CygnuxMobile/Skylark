import 'package:get/get.dart';
import 'prs_closure_controller.dart';

class PrsClosureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrsClosureController>(() => PrsClosureController());
  }
}

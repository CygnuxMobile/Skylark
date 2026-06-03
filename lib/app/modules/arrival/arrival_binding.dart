import 'package:get/get.dart';
import 'arrival_controller.dart';

class ArrivalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArrivalController>(() => ArrivalController());
  }
}

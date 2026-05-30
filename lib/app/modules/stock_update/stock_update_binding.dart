import 'package:get/get.dart';
import 'stock_update_controller.dart';

class StockUpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockUpdateController>(() => StockUpdateController());
  }
}

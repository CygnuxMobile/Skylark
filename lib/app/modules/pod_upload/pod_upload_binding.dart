import 'package:get/get.dart';
import 'pod_upload_controller.dart';

class PODUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PODUploadController>(() => PODUploadController());
  }
}

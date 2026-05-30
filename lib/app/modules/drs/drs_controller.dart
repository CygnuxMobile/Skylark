import 'package:get/get.dart';

class DrsController extends GetxController {
  var selectedVendorType = ''.obs;
  var vehicleNo = ''.obs;
  var tripSheet = ''.obs;
  var startKm = ''.obs;
  
  var isOwnVehicle = true.obs;

  List<String> vendorTypes = ['OWN', 'Market'];
  List<String> vehicles = ['KA01HJ8765', 'MH01AB1234', 'DL01CD5678'];
  List<String> tripSheets = ['TRGUR0001', 'TRMUM0002', 'TRDEL0003'];
  List<String> cNoteNumbers = [
    '123456789', '123456790', '123456791', '123456792', '123456793',
    '123456794', '123456795', '123456796', '123456797', '123456798'
  ];

  void onVendorTypeChanged(String? value) {
    selectedVendorType.value = value ?? '';
    isOwnVehicle.value = value == 'OWN';
  }

  void submit() {
    Get.snackbar("Success", "DRS Generated Successfully");
    Get.back();
  }
}

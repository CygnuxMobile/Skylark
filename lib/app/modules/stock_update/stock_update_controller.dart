import 'package:get/get.dart';
import 'package:flutter/material.dart';

class StockUpdateController extends GetxController {
  // List screen variables
  var manifestList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Detail screen variables
  var selectedManifest = Rxn<String>();
  final totalCnoteController = TextEditingController();
  final coLoaderNameController = TextEditingController();
  
  var dockets = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchManifestList();
  }

  void fetchManifestList() {
    // Mock data based on the image
    manifestList.value = [
      {'cdNo': 'CD 101', 'coloaderName': 'SKY EXPRESS', 'mfNo': 'MF9001', 'origin': 'GURGAON', 'dest': 'MUMBAI', 'totalBox': '45'},
      {'cdNo': 'CD 102', 'coloaderName': 'BLUE DART', 'mfNo': 'MF9002', 'origin': 'DELHI', 'dest': 'AHMEDABAD', 'totalBox': '30'},
      {'cdNo': 'CD 103', 'coloaderName': 'V-TRANS', 'mfNo': 'MF9003', 'origin': 'PUNE', 'dest': 'BANGALORE', 'totalBox': '120'},
    ];
  }

  void onManifestSelected(Map<String, dynamic> manifest) {
    selectedManifest.value = manifest['mfNo'];
    totalCnoteController.text = '3'; // Mock count
    coLoaderNameController.text = manifest['coloaderName'];
    
    // Mock dockets for the table as seen in your image
    dockets.value = [
      {'lr': '12321123', 'pc': '10', 'wt': '100', 'client': 'Biomerics Medical Products Pvt ltd', 'from': 'Gurgaon', 'to': 'Ahmedabad'},
      {'lr': '12987893', 'pc': '20', 'wt': '200', 'client': 'Wipro GE Healthcare Pvt Ltd', 'from': 'Gurgaon', 'to': 'Ahmedabad'},
      {'lr': '32572626', 'pc': '12', 'wt': '120', 'client': 'Siemens Healthcare Products Pvt Ltd', 'from': 'Gurgaon', 'to': 'Ahmedabad'},
    ];
    
    Get.toNamed('/stock-update-detail');
  }

  void submitStockUpdate() {
    Get.back();
    Get.snackbar(
      'Success', 
      'Stock Updated Successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    totalCnoteController.dispose();
    coLoaderNameController.dispose();
    super.onClose();
  }
}

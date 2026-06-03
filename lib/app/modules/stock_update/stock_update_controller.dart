import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';

class StockUpdateController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // List screen variables
  var manifestList = <dynamic>[].obs;
  var isLoading = false.obs;

  // Detail screen variables
  var selectedManifest = Rxn<String>();
  final totalCnoteController = TextEditingController();
  final coLoaderNameController = TextEditingController();
  
  var dockets = <Map<String, dynamic>>[].obs;

  // Filter variables
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();
  final thcNoFilterController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    fromDate.value = now.subtract(const Duration(days: 7));
    toDate.value = now;
    fetchManifestList();
  }

  Future<void> fetchManifestList() async {
    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      final location = _storageService.getLocation();
      
      final now = DateTime.now();
      final String fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate.value ?? now.subtract(const Duration(days: 7)));
      final String toDateStr = DateFormat('yyyy-MM-dd').format(toDate.value ?? now);

      final body = {
        "thcNo": thcNoFilterController.text,
        "fromDate": fromDateStr,
        "toDate": toDateStr,
        "transportMode": "S",
        "baseComapnyCode": user?.baseCompanyCode ?? "",
        "baseLocationCode": location?.locCode ?? ""
      };

      final response = await _apiService.post(
        AppConstants.stockUpdateListUrl,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['data'] != null && responseData['data'] is List) {
          manifestList.assignAll(responseData['data']);
        } else if (responseData is List) {
          manifestList.assignAll(responseData);
        }
      }
    } catch (e) {
      debugPrint("Error fetching Stock Update list: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onManifestSelected(Map<String, dynamic> manifest) {
    // Map API fields to UI variables
    selectedManifest.value = manifest['thcno'];
    totalCnoteController.text = (manifest['docketKount'] ?? '0').toString();
    coLoaderNameController.text = manifest['routename'] ?? '';
    
    // Map docket_BCSerials from API to the dockets list
    if (manifest['docket_BCSerials'] != null && manifest['docket_BCSerials'] is List) {
      final List<dynamic> serials = manifest['docket_BCSerials'];
      dockets.value = serials.map((e) => {
        'lr': e['dockno']?.toString() ?? '',
        'pc': '1',
        'wt': '0',
        'client': e['bcSerialNo']?.toString() ?? '',
        'from': manifest['thcbr'] ?? '',
        'to': manifest['tctobH_Code'] ?? '',
      }).toList();
    } else {
      dockets.clear();
    }
    
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
    thcNoFilterController.dispose();
    super.onClose();
  }
}

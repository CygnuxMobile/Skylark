import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';

class ArrivalController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  var isLoading = false.obs;
  var isSubmitting = false.obs;
  final RxList<dynamic> arrivalList = <dynamic>[].obs;

  // Filter variables
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();

  // Submit variables
  final closeKmController = TextEditingController();
  var selectedStatus = 'Ok'.obs;
  final List<String> statusItems = ['Ok', 'Broken', 'Unsealed'];

  @override
  void onInit() {
    super.onInit();

    final now = DateTime.now();
    toDate.value = now;
    fromDate.value = now.subtract(const Duration(days: 7));

    fetchArrivalList();
  }

  Future<void> fetchArrivalList() async {
    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      final location = _storageService.getLocation();

      final dateFormat = DateFormat('yyyy-MM-dd');
      final toDateStr = dateFormat.format(toDate.value ?? DateTime.now());
      final fromDateStr = dateFormat.format(fromDate.value ?? DateTime.now().subtract(const Duration(days: 7)));

      final body = {
        "thcNo": "",
        "fromDate": fromDateStr,
        "toDate": toDateStr,
        "transportMode": "S",
        "baseCompanyCode": user?.baseCompanyCode ?? "",
        "baseLocationCode": location?.locCode ?? ""
      };

      final response = await _apiService.post(AppConstants.thcArrivalsListUrl, data: body);

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['data'] != null && response.data['data'] is List) {
          arrivalList.assignAll(response.data['data']);
        } else {
          arrivalList.clear();
        }
      }
    } catch (e) {
      debugPrint("Error fetching arrival list: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitTHCArrival(Map<String, dynamic> arrival) async {
    if (closeKmController.text.isEmpty) {
      Get.snackbar("Error", "Please enter Close KM", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isSubmitting.value = true;
      final user = _storageService.getUser();
      final now = DateTime.now();

      final body = {
        "thcno": arrival['thcno'] ?? "",
        "brcd": arrival['nextLocation'] ?? "",
        "ad": DateFormat('MM-dd-yyyy hh:mm a').format(now),
        "at": DateFormat('HH:mm').format(now),
        "baseUserName": user?.userId ?? "",
        "isn": "",
        "status": selectedStatus.value,
        "closekm": int.tryParse(closeKmController.text) ?? 0,
        "ir": "",
        "transportMode": "S",
        "baseCompanyCode": user?.baseCompanyCode ?? "",
      };

      final response = await _apiService.post(AppConstants.thcArrivalSubmitUrl, data: body);

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['statusCode'] == 200) {
          Get.back(); // Close bottom sheet
          Get.snackbar("Success", response.data['message'] ?? "THC Arrival submitted successfully",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
          closeKmController.clear();
          selectedStatus.value = 'Ok';
          fetchArrivalList(); // Refresh list
        } else {
          // Handle API internal error
          Get.snackbar("Error", response.data['message'] ?? "Failed to submit THC arrival",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else {
        // Handle non-200 HTTP status
        Get.snackbar("Error", "Server error: ${response.statusCode}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error submitting THC arrival: $e");
      Get.snackbar("Error", "Failed to submit THC arrival", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    closeKmController.dispose();
    super.onClose();
  }
}

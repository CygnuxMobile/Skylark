import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';

import '../../routes/app_routes.dart';

class PrsClosureController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final prsNoController = TextEditingController();
  final vendorNameController = TextEditingController();
  final freightAmtController = TextEditingController();
  final otherAmtController = TextEditingController();
  final finalBalController = TextEditingController();

  var isLoading = false.obs;
  var isLoadingVendors = false.obs;
  var selectedVendorType = ''.obs;
  final RxList<dynamic> prsList = <dynamic>[].obs;
  final RxList<dynamic> vendorList = <dynamic>[].obs;
  var selectedPrs = Rxn<Map<String, dynamic>>();
  var selectedVendor = Rxn<dynamic>();

  // Filter variables
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    
    // Default dates: Today and 7 days ago
    final now = DateTime.now();
    toDate.value = now;
    fromDate.value = now.subtract(const Duration(days: 7));
    
    freightAmtController.addListener(_calculateFinalBalance);
    otherAmtController.addListener(_calculateFinalBalance);
    fetchPrsList();
    fetchVendors();
  }

  Future<void> fetchVendors() async {
    try {
      isLoadingVendors.value = true;
      final location = _storageService.getLocation();
      final user = _storageService.getUser();

      final body = {
        "vendor_Type": "XX",
        "location": location?.locCode ?? "",
        "username": user?.userId ?? "",
        "documentType": "PRS"
      };

      final response = await _apiService.post(AppConstants.getVendorsUrl, data: body);

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['data'] != null && response.data['data'] is Map) {
          final dataMap = response.data['data'] as Map;
          if (dataMap['venderscodes'] != null && dataMap['venderscodes'] is List) {
            vendorList.assignAll(dataMap['venderscodes']);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching Vendors: $e");
    } finally {
      isLoadingVendors.value = false;
    }
  }

  Future<void> fetchPrsList() async {
    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      final location = _storageService.getLocation();
      
      final now = DateTime.now();
      final String fromDateStr = DateFormat('dd MMM yyyy').format(fromDate.value ?? now.subtract(const Duration(days: 7)));
      final String toDateStr = DateFormat('dd MMM yyyy').format(toDate.value ?? now);

      final body = {
        "baseLocationCode": location?.locCode ?? "",
        "dateFrom": fromDateStr,
        "dateTo": toDateStr,
        "baseCompanyCode": user?.baseCompanyCode ?? ""
      };

      final response = await _apiService.post(
        AppConstants.prsListUrl,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['data'] != null && responseData['data'] is Map) {
          final dataMap = responseData['data'] as Map;
          if (dataMap['prsLists'] != null && dataMap['prsLists'] is List) {
            prsList.assignAll(dataMap['prsLists']);
          } else {
            prsList.clear();
          }
        } else if (responseData['data'] != null && responseData['data'] is List) {
          prsList.assignAll(responseData['data']);
        } else {
          prsList.clear();
        }
      }
    } catch (e) {
      debugPrint("Error fetching PRS list: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onPrsSelected(Map<String, dynamic> prs) {
    selectedPrs.value = prs;
    prsNoController.text = prs['pdcno'] ?? '';
    vendorNameController.text = prs['vendorname'] ?? prs['deliveryAgent'] ?? '';
    selectedVendorType.value = prs['vendor_type']?.toString() ?? '';
    freightAmtController.text = '0';
    otherAmtController.text = '0';
    finalBalController.text = '0';
    selectedVendor.value = null;

    if (vendorList.isNotEmpty) {
      final vendorCode = (prs['vendor_code'] ?? prs['vendor_Code'])?.toString();
      if (vendorCode != null) {
        selectedVendor.value = vendorList.firstWhere(
          (v) => (v['vendor_code'] ?? v['vendor_Code'])?.toString() == vendorCode,
          orElse: () => null,
        );
      }
    }
    
    Get.toNamed(AppRoutes.prsClosureDetail);
  }

  void _calculateFinalBalance() {
    double freight = double.tryParse(freightAmtController.text) ?? 0;
    double other = double.tryParse(otherAmtController.text) ?? 0;
    finalBalController.text = (freight + other).toStringAsFixed(0);
  }

  Future<void> submit() async {
    if (vendorNameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter Vendor Name",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    if (selectedVendorType.value == '01') {
      if (freightAmtController.text.trim().isEmpty) {
        Get.snackbar("Error", "Please enter Freight Amt",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }
      if (otherAmtController.text.trim().isEmpty) {
        Get.snackbar("Error", "Please enter Other Amt",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }
    }

    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      final prsData = selectedPrs.value;
      
      final List<dynamic> prsDocktLists = prsData?['prsDocktLists'] ?? [];
      
      final body = {
        "prs": {
          "prsNo": prsNoController.text,
          "loading_VendorCode": selectedVendor.value?['vendor_code'] ?? selectedVendor.value?['vendor_Code'] ?? prsData?['vendor_code'] ?? prsData?['vendor_Code'] ?? "",
          "loading_VendorName": vendorNameController.text,
          "freigthamt": double.tryParse(freightAmtController.text) ?? 0,
          "otherant": double.tryParse(otherAmtController.text) ?? 0,
          "finalamt": double.tryParse(finalBalController.text) ?? 0,
          "rate": 0,
          "rateType": "",
          "loadingCharge": 0,
          "baseUserName": user?.userId ?? ""
        },
        "prsList": prsDocktLists.map((d) => {
          "prsNo": prsNoController.text,
          "dockno": d['dockno'] ?? '',
          "newRate": 0,
          "ratetype1": "1"
        }).toList()
      };

      final response = await _apiService.post(
        AppConstants.prsArrivalUrl,
        data: body,
      );

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        Get.snackbar("Error", response.data?['message'] ?? "Failed to close PRS",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error submitting PRS Arrival: $e");
      Get.snackbar("Error", "An error occurred during submission",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'PRS Closed Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Go back to list screen
                    fetchPrsList(); // Refresh list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    prsNoController.dispose();
    vendorNameController.dispose();
    freightAmtController.dispose();
    otherAmtController.dispose();
    finalBalController.dispose();
    super.onClose();
  }
}

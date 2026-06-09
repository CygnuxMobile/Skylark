import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';

import 'package:skylark/app/core/widgets/custom_snackbar.dart';

class ManifestController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  var fromDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  var toDate = DateTime.now().obs;
  var isLoading = false.obs;
  
  // Master list from API
  var manifestList = <Map<String, dynamic>>[].obs;
  // List shown on UI (Filtered)
  var filteredManifestList = <Map<String, dynamic>>[].obs;
  
  final TextEditingController thcSearchController = TextEditingController();
  var searchText = "".obs;

  // Detail Screen State
  var isLoadingDetails = false.obs;
  var isSubmitting = false.obs;
  var detailData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    thcSearchController.addListener(_onSearchChanged);
    fetchManifestList();
  }

  void _onSearchChanged() {
    searchText.value = thcSearchController.text.trim();
    _applyFilter();
  }

  void _applyFilter() {
    if (searchText.value.isEmpty) {
      filteredManifestList.assignAll(manifestList);
    } else {
      final query = searchText.value.toLowerCase();
      filteredManifestList.assignAll(
        manifestList.where((item) {
          final mfNo = (item['mf'] ?? "").toString().toLowerCase();
          return mfNo.contains(query);
        }).toList(),
      );
    }
  }

  Future<void> fetchManifestList() async {
    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      final location = _storageService.getLocation();
      
      final dateFormat = DateFormat('dd MMM yy');

      final body = {
        "thcNo": "",
        "fromDate": dateFormat.format(fromDate.value),
        "toDate": dateFormat.format(toDate.value),
        "transportMode": "S",
        "baseComapnyCode": user?.baseCompanyCode ?? "C003",
        "baseLocationCode": location?.locCode ?? "AHM"
      };

      final response = await _apiService.post(
        AppConstants.arrivalStockUpdateListUrl,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data['data'] != null) {
          data = response.data['data'];
        } else if (response.data is List) {
          data = response.data;
        }
        
        final list = data.map((e) => Map<String, dynamic>.from(e)).toList();
        manifestList.assignAll(list);
        _applyFilter();
      } else {
        manifestList.clear();
        filteredManifestList.clear();
      }
    } catch (e) {
      debugPrint("Error fetching manifest list: $e");
      manifestList.clear();
      filteredManifestList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchManifestDetails(String mfNo) async {
    try {
      isLoadingDetails.value = true;
      detailData.clear();
      
      final location = _storageService.getLocation();
      
      final response = await _apiService.post(
        AppConstants.arrivalStockUpdateDetailUrl,
        data: {
          "mfno": mfNo,
          "brcd": location?.locCode ?? "AHM"
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = response.data['data'] ?? [];
        detailData.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (e) {
      debugPrint("Error fetching details: $e");
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> submitManifest({
    required String status,
    required String remark,
    required String destinationKm,
  }) async {
    if (detailData.isEmpty) {
      CustomSnackbar.error(message: "No docket data found to submit");
      return;
    }

    try {
      isSubmitting.value = true;
      final user = _storageService.getUser();
      final location = _storageService.getLocation();
      
      // Formatting date like: 6/4/2026 12:00:00 AM
      final now = DateTime.now();
      final formattedDate = DateFormat('M/d/yyyy h:mm:ss a').format(now);

      final firstItem = detailData[0];

      final body = {
        "updateDate": formattedDate,
        "baseUserName": user?.userId,
        "baseLocationCode": location?.locCode,
        "thcno": firstItem['thcno'],
        "ad": formattedDate,
        "at": "",
        "isn": "252525",
        "status": status,
        "lar": "",
        "ir": "",
        "openkm": firstItem['openkm']?.toString() ?? "1.00",
        "closekm": destinationKm,
        "seal_Reason": remark,
        "loadingCharge": 0,
        "rate": 0,
        "loadingBy": "XX9",
        "mathadiDate": "0001-01-01T00:00:00.000Z",
        "isCPArr": "Y",
        "stockUpdateDetails": detailData.map((e) => {
          "tcno": e['tcno'] ?? "",
          "dockNo": e['dockNo'] ?? "",
          "dockSF": e['dockSF'] ?? ".",
          "bkG_PKGSNO": e['bkG_PKGSNO'] ?? 0,
          "pkgsno": e['pkgsno'] ?? 0,
          "bkG_ACTUWT": e['bkG_ACTUWT'] ?? 0.0,
          "actuwt": e['actuwt'] ?? 0.0,
          "ac": "1",
          "wi": "",
          "cdelydt": "01/01/1900",
          "delyreason": "-",
          "dp": "2",
          "coddodAmount": e['coddodAmount'] ?? 0,
          "coddodcollected": e['coddodcollected'] ?? 0,
          "coddod": e['coddod'] ?? "",
          "isCounterDelivery": e['isCounterDelivery'] ?? false,
          "shortageQty": 0,
          "shortageWeight": 0,
          "shortageReason": "",
          "shortageRemarks": "",
          "pilferageQty": 0,
          "pilferageWeight": 0,
          "pilferageReason": "",
          "pilferageRemarks": "",
          "damageQry": 0,
          "damageWeight": 0,
          "damageReason": "",
          "damageRemarks": "",
          "isCODDODChar": e['isCODDODChar'] ?? "",
          "delyperson": "-",
          "isAllgood": false,
          "isCheckRemarks": remark,
          "pilferageFileName": [],
          "damageFileName": []
        }).toList()
      };
      final response = await _apiService.post(
        AppConstants.arrivalStockUpdateSubmitUrl,
        data: body,
      );
      
      debugPrint("StatusCode = ${response.statusCode}");
      debugPrint("Response Data = ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['data'] == "Done") {
          _showStatusDialog(
            title: "Success!",
            message: "Manifest submitted successfully",
            isSuccess: true,
            onDone: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to list
              fetchManifestList();
            },
          );
        } else {
          _showStatusDialog(
            title: "Failed",
            message: "Not Success" ?? "Submission failed (Not Done)",
            isSuccess: false,
          );
        }
      } else {
        _showStatusDialog(
          title: "Error",
          message: response.data?['message'] ?? "Submission failed",
          isSuccess: false,
        );
      }
    } catch (e) {
      debugPrint("Error submitting manifest: $e");
      _showStatusDialog(
        title: "Error",
        message: "Something went wrong",
        isSuccess: false,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showStatusDialog({
    required String title,
    required String message,
    required bool isSuccess,
    VoidCallback? onDone,
  }) {
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
                  color: (isSuccess ? Colors.green : Colors.red).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDone ?? () => Get.back(),
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

  void updateFromDate(DateTime date) {
    fromDate.value = date;
    fetchManifestList();
  }

  void updateToDate(DateTime date) {
    toDate.value = date;
    fetchManifestList();
  }

  void clearSearch() {
    thcSearchController.clear();
  }

  @override
  void onClose() {
    thcSearchController.removeListener(_onSearchChanged);
    thcSearchController.dispose();
    super.onClose();
  }
}

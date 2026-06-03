import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/models/drs_closure_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';
import '../../routes/app_routes.dart';

class DrsClosureController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final drsNoController = TextEditingController();
  final vendorNameController = TextEditingController();
  final freightAmtController = TextEditingController();
  final otherAmtController = TextEditingController();
  final finalBalController = TextEditingController();

  var isLoading = false.obs;
  var selectedVendorType = ''.obs;
  final RxList<dynamic> drsList = <dynamic>[].obs;
  final RxList<dynamic> drsDetailList = <dynamic>[].obs;
  var selectedDrs = Rxn<Map<String, dynamic>>();
  var drsHeaderData = Rxn<Map<String, dynamic>>();

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
    fetchDrsList();
  }

  Future<void> fetchDrsList() async {
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
        AppConstants.drsListUrl,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['data'] != null && responseData['data'] is Map) {
          final dataMap = responseData['data'] as Map;
          if (dataMap['drsLists'] != null && dataMap['drsLists'] is List) {
            drsList.assignAll(dataMap['drsLists']);
          } else {
            drsList.clear();
          }
        } else if (responseData['data'] != null && responseData['data'] is List) {
          drsList.assignAll(responseData['data']);
        } else {
          drsList.clear();
        }
      }
    } catch (e) {
      debugPrint("Error fetching DRS list: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onDrsSelected(Map<String, dynamic> drs) async {
    try {
      isLoading.value = true;
      selectedDrs.value = drs;

      final location = _storageService.getLocation();

      final body = {
        "drsId": drs['pdcno'] ?? "",
        "baseLocationCode": location?.locCode ?? ""
      };

      final response = await _apiService.post(
        AppConstants.updateDrsDetailsUrl,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data['data'];
        if (responseData != null) {
          drsHeaderData.value = responseData;
          if (responseData['drsDetail'] != null &&
              responseData['drsDetail'] is List) {
            drsDetailList.assignAll(responseData['drsDetail']);
          }

          drsNoController.text = responseData['pdcno'] ?? '';
          vendorNameController.text = responseData['bA_Vendor_Code'] ?? '';
          selectedVendorType.value = drs['vendor_type']?.toString() ?? '';
          
          freightAmtController.text = '0';
          otherAmtController.text = '0';
          finalBalController.text = '0';

          Get.toNamed(AppRoutes.drsClosureDetail);
        }
      } else {
        Get.snackbar("Error", "Failed to fetch DRS details",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error fetching DRS details: $e");
      Get.snackbar("Error", "Something went wrong: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
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
      double freight = double.tryParse(freightAmtController.text) ?? 0;
      double other = double.tryParse(otherAmtController.text) ?? 0;
      
      if (freight <= 0 && other <= 0) {
        Get.snackbar("Error", "Please enter Freight or Other Amt",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }
    }

    try {
      isLoading.value = true;
      final header = drsHeaderData.value;
      if (header == null) return;

      final user = _storageService.getUser();

      final drsSummary = DrsSummary(
        pdcno: header['pdcno'] ?? "",
        pdCDt: header['pdC_Dt'] ?? "",
        deliveryBy: header['deliveryBy'] ?? "",
        bAVendorCode: header['bA_Vendor_Code'] ?? "",
        staff: header['staff'] ?? "",
        driverName: header['driverName'] ?? ".",
        vehno: header['vehno'] ?? "",
        startKm: (header['start_KM'] ?? 0).toDouble(),
        totalDocketsInDrs: (header['total_Dockets_In_DRS'] ?? 0).toInt(),
        closeKm: (header['closeKM'] ?? 0).toDouble(),
        pdCUpdated: "No",
        fromDate: header['pdC_Dt'] ?? "",
        toDate: header['pdC_Dt'] ?? "",
        drsNoList: header['pdcno'] ?? "",
        dockno: drsDetailList.isNotEmpty ? drsDetailList[0]['dockno'] : "",
        dockdt: drsDetailList.isNotEmpty ? drsDetailList[0]['booking_Date'] : "",
        drs: header['pdcno'] ?? "",
        drSDt: header['pdC_Dt'] ?? "",
        autoNo: (header['autoNo'] ?? 0).toInt(),
        loadingBy: "",
        rateType: "0",
        loadingCharge: 0,
        rate: 0,
        maxLimit: 0,
        vendorCode: (header['bA_Vendor_Code'] ?? "").toString().split(':').first.trim(),
        vendorName: vendorNameController.text.trim(),
        isMonthly: false,
        hdnRate: 0,
        isMathadi: false,
        mathadiSlipNo: "",
        mathadiDate: "",
        mathadiAmt: 0,
        pkgsno: (header['pkgsno'] ?? 0).toInt(),
        actuwt: 0,
        drsDate: header['pdC_Dt'] ?? "",
        frtAmt: double.tryParse(freightAmtController.text) ?? 0,
        othAmt: double.tryParse(otherAmtController.text) ?? 0,
        finAmt: double.tryParse(finalBalController.text) ?? 0,
      );

      final updateDRSLits = drsDetailList.map((item) {
        return UpdateDrsList(
          autoNo: (item['autoNo'] ?? 0).toInt(),
          dockno: item['dockno'] ?? "",
          docksf: item['docksf'] ?? ".",
          bookingDate: item['booking_Date'] ?? "",
          orgncd: item['orgncd'] ?? "",
          destcd: item['destcd'] ?? "",
          payBasis: item['payBasis'] ?? "",
          csgncd: item['csgncd'] ?? "",
          csgnnm: item['csgnnm'] ?? "",
          csgecd: item['csgecd'] ?? "",
          csgenm: item['csgenm'] ?? "",
          pkgsArrived: (item['pkgs_Arrived'] ?? 0).toInt(),
          pkgsBooked: (item['pkgs_Booked'] ?? 0).toInt(),
          pkgsPending: (item['pkgs_Pending'] ?? 0).toInt(),
          bookedWt: (item['booked_Wt'] ?? 0).toDouble(),
          wtArrived: (item['wt_Arrived'] ?? 0).toDouble(),
          commDelyDt: item['comm_Dely_Dt'] ?? "",
          freight: (item['freight'] ?? 0).toDouble(),
          docketTotal: (item['docket_Total'] ?? 0).toDouble(),
          serviceTax: (item['service_Tax'] ?? 0).toDouble(),
          delyLocation: item['delyLocation'] ?? "",
          currLoc: item['curr_loc'] ?? "",
          payBasCode: item['payBasCode'] ?? "",
          dockDt: item['dockDt'] ?? "",
          coDDod: item['coD_DOD'] ?? "N",
          coddodAmount: (item['coddodAmount'] ?? 0).toDouble(),
          cdeldTDdmmyyyy: item['cdeldT_ddmmyyyy'] ?? "",
          dockDtDdmmyyyy: item['dockDt_ddmmyyyy'] ?? "",
          dlypdcno: item['dlypdcno'] ?? "",
          coddod: item['coddod'] ?? false,
          pkgsdelivered: (item['pkgsdelivered'] ?? item['pkgs_Arrived'] ?? 0).toInt(),
          remark: item['remark'] ?? "OK",
          otp: item['otp'] ?? "",
          delydate: "",
          delytime:
          "",
          delyperson: item['delyperson'] ?? "",
          cboReason: item['cboReason'] ?? "",
          coddodcollected: (item['coddodcollected'] ?? 0).toInt(),
          coddodno: (item['coddodno'] ?? 0).toInt(),
          cboLateReason: item['cboLateReason'] ?? "",
          hDcboReason: item['hDcboReason'] ?? "",
          isChecked: true,
          pkgQty: (item['pkgQty'] ?? 0).toInt(),
          actQty: (item['actQty'] ?? 0).toInt(),
          rate: (item['rate'] ?? 0).toDouble(),
          maxLimit: (item['maxLimit'] ?? 0).toDouble(),
          newRate: (item['newRate'] ?? 0).toDouble(),
          ratetype: item['ratetype'] ?? "",
          isEnabled: true,
          isEnabledBadPodoption: true,
          backPod: "",
          frontPod: "",
        );
      }).toList();

      final requestBody = DrsClosureRequestModel(
        drsSummary: drsSummary,
        updateDRSLits: updateDRSLits,
        loadingCharge: 0,
        baseUserName: user?.userId ?? "",
      );

      final response = await _apiService.post(
        AppConstants.updateDrsUrl,
        data: requestBody.toJson(),
      );

      if (response.statusCode == 200 && response.data?['status'] == 200) {
        _showSuccessDialog();
      } else {
        String errorMsg = response.data?['errors']?['message'] ?? 
                         response.data?['message'] ?? 
                         "Failed to close DRS";
        
        Get.snackbar("Error", errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error submitting DRS closure: $e");
      Get.snackbar("Error", "Something went wrong: $e",
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
                    shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.green, size: 60),
              ),
              const SizedBox(height: 20),
              const Text(
                'Success!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue),
              ),
              const SizedBox(height: 12),
              const Text(
                'DRS Closed successfully',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    fetchDrsList(); // Refresh list
                    Get.back(); // Go back to list screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.white),
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
    drsNoController.dispose();
    vendorNameController.dispose();
    freightAmtController.dispose();
    otherAmtController.dispose();
    finalBalController.dispose();
    super.onClose();
  }
}

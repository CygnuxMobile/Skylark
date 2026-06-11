import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'package:skylark/app/data/models/prs_request_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';

class DrsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();

  var selectedOrigin = Rxn<LocationModel>();
  final RxList<LocationModel> locations = <LocationModel>[].obs;
  var isLoadingLocations = false.obs;

  final selectedVendorType = RxnString();
  final vehicleNo = RxnString();
  final tripSheet = RxnString();
  var startKm = ''.obs;

  var isOwnVehicle = true.obs;
  var isVehicleNoValid = true.obs;

  List<String> vendorTypes = ['OWN', 'Market'];

  final RxList<String> vehicles = <String>[].obs;
  var isLoadingVehicles = false.obs;

  final RxList<String> tripSheets = <String>[].obs;
  var isLoadingTripSheets = false.obs;

  final cnoteController = TextEditingController();
  final RxList<String> selectedCnotes = <String>[].obs;
  final RxList<Map<String, dynamic>> selectedCnoteData = <Map<String, dynamic>>[].obs;
  var isValidatingCnote = false.obs;
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    getOriginLocation();
    getLocationMasterData();
  }

  void getOriginLocation() {
    final location = _storageService.getLocation();
    if (location != null) {
      selectedOrigin.value = location;
    }
  }

  void onOriginLocationChanged(LocationModel? value) {
    selectedOrigin.value = value;
    if (value != null) {
      _storageService.saveLocation(value);
      if (isOwnVehicle.value) {
        getVehicleNumbers();
      }
    }
  }

  Future<void> getLocationMasterData() async {
    try {
      isLoadingLocations.value = true;
      final user = _storageService.getUser();
      final userId = user?.userId ?? "";
      final response = await _apiService.get(AppConstants.getLocationMasterDataUrl, queryParameters: {'UserID': userId});

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data['data'] is List) {
          data = response.data['data'];
        }

        locations.assignAll(data.map((e) => LocationModel.fromJson(e)).toList());
      }
    } catch (e) {
      debugPrint("Error fetching locations: $e");
    } finally {
      isLoadingLocations.value = false;
    }
  }

  void onVendorTypeChanged(String? value) {
    selectedVendorType.value = value;
    isOwnVehicle.value = value == 'OWN';
    vehicleNo.value = null;
    isVehicleNoValid.value = true;
    tripSheets.clear();
    tripSheet.value = null;
    if (isOwnVehicle.value) {
      getVehicleNumbers();
    }
  }

  void onVehicleNoChanged(String? value) {
    String formattedValue = (value ?? '').replaceAll(' ', '').toUpperCase();
    vehicleNo.value = formattedValue;

    final RegExp vehicleRegex = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{0,3}[0-9]{4}$');

    if (isOwnVehicle.value) {
      isVehicleNoValid.value = true;
      if (formattedValue.isNotEmpty) {
        getTripSheetNumbers(formattedValue);
      }
    } else {
      isVehicleNoValid.value = formattedValue.isEmpty || vehicleRegex.hasMatch(formattedValue);
      if (vehicleRegex.hasMatch(formattedValue)) {
        getTripSheetNumbers(formattedValue);
      } else {
        tripSheets.clear();
        tripSheet.value = null;
      }
    }
  }

  Future<void> getVehicleNumbers() async {
    try {
      isLoadingVehicles.value = true;
      final location = _storageService.getLocation();
      final baseLocationCode = location?.locCode ?? "";

      final response = await _apiService.get(AppConstants.getVehicleNoUrl, queryParameters: {'baseLocationCode': baseLocationCode, 'VendorType': '05'});

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data['data'] is List) {
          data = response.data['data'];
        }

        if (data.isNotEmpty) {
          vehicles.assignAll(data.map((e) => e['vehno'].toString()).toList());
        }
      }
    } catch (e) {
      debugPrint("Error fetching vehicles: $e");
    } finally {
      isLoadingVehicles.value = false;
    }
  }

  Future<void> getTripSheetNumbers(String vehNo) async {
    try {
      isLoadingTripSheets.value = true;
      tripSheets.clear();
      final response = await _apiService.get(AppConstants.getTripsheetNoUrl, queryParameters: {'vehno': vehNo});

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data['data'] is List) {
          data = response.data['data'];
        } else if (response.data is List) {
          data = response.data;
        }

        if (data.isNotEmpty) {
          tripSheets.assignAll(data.map((e) => e['tripNo'].toString()).toList());
        }
      }
    } catch (e) {
      debugPrint("Error fetching trip sheets: $e");
    } finally {
      isLoadingTripSheets.value = false;
    }
  }

  Future<void> addCnote() async {
    final cnote = cnoteController.text.trim();
    if (cnote.isEmpty) return;

    if (selectedCnotes.contains(cnote)) {
      Get.snackbar("Error", "Cnote already added", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isValidatingCnote.value = true;
      final location = _storageService.getLocation();
      final user = _storageService.getUser();

      final now = DateTime.now();
      final fromDate = now.subtract(const Duration(days: 30));
      final dateFormat = DateFormat('dd MMM yyyy');

      final body = {
        "fromdt": dateFormat.format(fromDate),
        "todt": dateFormat.format(now),
        "dttyp": "1",
        "paybas": "All",
        "trn": "All",
        "bustyp": "All",
        "status": "P",
        "doctyp": "DRS",
        "baseLocationCode": location?.locCode ?? "",
        "docketList": cnote,
        "alloted_To": "",
        "loadingBy": "XX9",
        "chrgType": "",
        "baseCompanyCode": user?.baseCompanyCode ?? "",
      };

      final response = await _apiService.post(AppConstants.getAvailableDocketUrl, data: body);

      if (response.statusCode == 200 && response.data != null) {
        dynamic responseData = response.data['data'];
        bool isValid = false;
        Map<String, dynamic>? docketData;

        if (responseData != null) {
          if (responseData is List && responseData.isNotEmpty) {
            isValid = true;
            docketData = responseData[0];
          } else if (responseData is Map && responseData.isNotEmpty) {
            isValid = true;
            docketData = responseData as Map<String, dynamic>;
          }
        }

        if (isValid && docketData != null) {
          selectedCnotes.add(cnote);
          selectedCnoteData.add(docketData);
          cnoteController.clear();
        } else {
          cnoteController.clear();
          Get.snackbar("Invalid Cnote", "This Cnote number is not available for DRS.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", "Failed to validate Cnote", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error validating Cnote: $e");
      Get.snackbar("Error", "An error occurred while validating Cnote", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isValidatingCnote.value = false;
    }
  }

  void removeCnote(int index) {
    selectedCnotes.removeAt(index);
    selectedCnoteData.removeAt(index);
  }

  @override
  void onClose() {
    cnoteController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (!isVehicleNoValid.value) {
      Get.snackbar("Error", "Please enter a valid Indian vehicle number", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (vehicleNo.value == null || vehicleNo.value!.isEmpty) {
      Get.snackbar("Error", "Please select/enter Vehicle No", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedCnotes.isEmpty) {
      Get.snackbar("Error", "Please add at least one Cnote", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSubmitting.value = true;
      final user = _storageService.getUser();
      final location = _storageService.getLocation();

      final requestBody = PrsRequestModel(
        prsNo: "",
        prscDate: DateTime.now(),
        entryBy: user?.userId ?? "",
        vendorcode: "",
        vendorname: "",
        vehicleNo: vehicleNo.value ?? "",
        vendorType: isOwnVehicle.value ? "05" : "01",
        tripsheetno: tripSheet.value ?? "",
        fromCity: "",
        toCity: "",
        baseUserName: user?.userId ?? "",
        baseLocationCode: location?.locCode ?? "",
        baseCompanyCode: user?.baseCompanyCode ?? "",
        baseFinYear: user?.finYear ?? "",
        docType: "DRS",
        startKm: startKm.value.isEmpty ? "0" : startKm.value,
        cdNo: "",
        prsGenerateList: selectedCnoteData
            .map(
              (e) => PrsGenerateList(
                dockno: e['dockno'].toString(),
                docksf: (e['docksf'] ?? ".").toString(),
                orgncd: e['orgncd'].toString(),
                pkgsno: (e['pkgsno'] ?? 0).toInt(),
                arrPkgQty: (e['arrPkgQty'] ?? 0).toInt(),
                pendPkgQty: (e['pendPkgQty'] ?? 0).toInt(),
                payBas: (e['payBas'] ?? "").toString(),
                actuwt: (e['actuwt'] ?? 0.0).toDouble(),
                arrWeightQty: (e['arrWeightQty'] ?? 0.0).toDouble(),
                chrgwt: (e['chrgwt'] ?? 0.0).toDouble(),
                trNMod: (e['trN_MOD'] ?? "").toString(),
                dkttot: (e['dkttot'] ?? 0).toInt(),
                desTCd: (e['desT_CD'] ?? "").toString(),
                pdcdt: DateTime.tryParse(e['pdcdt']?.toString() ?? "") ?? DateTime.now(),
                bkgDate: DateTime.tryParse((e['bkg_Date'] ?? e['dockdt'])?.toString() ?? "") ?? DateTime.now(),
                rate: (e['rate'] ?? 0).toInt(),
                ratetype: (e['ratetype'] ?? 0).toInt(),
              ),
            )
            .toList(),
      );

      final response = await _apiService.post(AppConstants.preparePrsUrl, data: requestBody.toJson());

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['statusCode'] == 200) {
          final drsNo = response.data['data'];
          _showSuccessDialog(drsNo);
        } else {
          Get.snackbar("Error", response.data['message'] ?? "Submission failed", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      debugPrint("Error submitting DRS: $e");
      Get.snackbar("Error", "An error occurred during submission", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showSuccessDialog(String drsNo) {
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
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 60),
              ),
              const SizedBox(height: 20),
              const Text(
                'Success!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
              ),
              const SizedBox(height: 12),
              const Text(
                'DRS generated successfully',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                    Text(
                      drsNo,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white),
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
}

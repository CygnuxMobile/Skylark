import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';

class DrsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();

  final vehicleNoController = TextEditingController();
  final tripSheetController = TextEditingController();

  var selectedVendorType = ''.obs;
  var vehicleNo = ''.obs;
  var tripSheet = ''.obs;
  var startKm = ''.obs;
  
  var isOwnVehicle = true.obs;

  List<String> vendorTypes = ['OWN', 'Market'];
  
  final RxList<String> vehicles = <String>[].obs;
  var isLoadingVehicles = false.obs;
  
  final RxList<String> tripSheets = <String>[].obs;
  var isLoadingTripSheets = false.obs;

  List<String> cNoteNumbers = [
    '123456789', '123456790', '123456791', '123456792', '123456793',
    '123456794', '123456795', '123456796', '123456797', '123456798'
  ];

  void onVendorTypeChanged(String? value) {
    selectedVendorType.value = value ?? '';
    isOwnVehicle.value = value == 'OWN';
    vehicleNo.value = '';
    vehicleNoController.clear();
    tripSheets.clear();
    tripSheet.value = '';
    tripSheetController.clear();
    if (isOwnVehicle.value) {
      getVehicleNumbers();
    }
  }

  void onVehicleNoChanged(String value) {
    String formattedValue = value.replaceAll(' ', '').toUpperCase();
    vehicleNo.value = formattedValue;
    if (vehicleNoController.text != formattedValue) {
      vehicleNoController.text = formattedValue;
    }

    final RegExp vehicleRegex = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{0,3}[0-9]{4}$');

    if (isOwnVehicle.value) {
      if (formattedValue.isNotEmpty) {
        getTripSheetNumbers(formattedValue);
      }
    } else {
      if (vehicleRegex.hasMatch(formattedValue)) {
        getTripSheetNumbers(formattedValue);
      } else {
        tripSheets.clear();
        tripSheet.value = '';
      }
    }
  }

  Future<void> getVehicleNumbers() async {
    try {
      isLoadingVehicles.value = true;
      final location = _storageService.getLocation();
      final baseLocationCode = location?.locCode ?? "";
      
      final response = await _apiService.get(
        'Operation/GetVehicleNo', 
        queryParameters: {
          'baseLocationCode': baseLocationCode,
          'VendorType': 'XX1'
        }
      );
      
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data['data'] is List) {
          data = response.data['data'];
        }
        vehicles.assignAll(data.map((e) => e['vehno'].toString()).toList());
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
      final response = await _apiService.get(
        'Operation/GetTripsheetNo',
        queryParameters: {'vehno': vehNo},
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data['data'] is List) {
          data = response.data['data'];
        } else if (response.data is List) {
          data = response.data;
        }

        if (data.isNotEmpty) {
          tripSheets.assignAll(data.map((e) => e['tripNo'].toString()).toList());
        } else {
          tripSheets.clear();
          if (!isOwnVehicle.value) {
            debugPrint("No trip sheets found for vehicle: $vehNo");
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching trip sheets: $e");
      tripSheets.clear();
    } finally {
      isLoadingTripSheets.value = false;
    }
  }

  void submit() {
    Get.snackbar("Success", "DRS Generated Successfully");
    Get.back();
  }

  @override
  void onClose() {
    vehicleNoController.dispose();
    tripSheetController.dispose();
    super.onClose();
  }
}

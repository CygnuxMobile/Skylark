import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';

class PrsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();
  
  final originController = TextEditingController();
  var origin = ''.obs;
  var selectedOrigin = Rxn<LocationModel>();
  
  final RxList<LocationModel> locations = <LocationModel>[].obs;
  var isLoadingLocations = false.obs;
  var selectedLocation = Rxn<LocationModel>();

  var selectedCoLoader = ''.obs;
  var selectedVendorType = ''.obs;
  var vehicleNo = ''.obs;
  var tripSheet = ''.obs;
  
  var isLocalLocation = true.obs;
  var isOwnVehicle = true.obs;

  List<String> coLoaders = ['Shekhavati road Carrier', 'V-Trans', 'Safexpress'];
  List<String> vendorTypes = ['OWN', 'Market'];
  final RxList<String> vehicles = <String>[].obs;
  var isLoadingVehicles = false.obs;
  final RxList<String> tripSheets = <String>[].obs;
  var isLoadingTripSheets = false.obs;
  List<String> cNoteNumbers = [
    '123456789', '123456790', '123456791', '123456792', '123456793',
    '123456794', '123456795', '123456796', '123456797', '123456798'
  ];

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
      origin.value = location.locName ?? '';
      originController.text = origin.value;
    }
  }

  void onOriginLocationChanged(LocationModel? value) {
    selectedOrigin.value = value;
    origin.value = value?.locName ?? '';
    if (value != null) {
      _storageService.saveLocation(value);
    }
    onLocationChanged(selectedLocation.value);
  }

  Future<void> getLocationMasterData() async {
    try {
      isLoadingLocations.value = true;
      final user = _storageService.getUser();
      final userId = user?.userId ?? "";
      final response = await _apiService.get('Master/GetLocationMasterData', queryParameters: {'UserID': userId});
      
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

  @override
  void onClose() {
    originController.dispose();
    super.onClose();
  }

  void onLocationChanged(LocationModel? value) {
    selectedLocation.value = value;
    if (value?.locName == origin.value) {
      isLocalLocation.value = true;
      selectedCoLoader.value = '';
    } else {
      isLocalLocation.value = false;
    }
  }

  void onVendorTypeChanged(String? value) {
    selectedVendorType.value = value ?? '';
    isOwnVehicle.value = value == 'OWN';
    vehicleNo.value = '';
    tripSheets.clear();
    tripSheet.value = '';
    if (isOwnVehicle.value) {
      getVehicleNumbers();
    }
  }

  void onVehicleNoChanged(String value) {
    String formattedValue = value.replaceAll(' ', '').toUpperCase();
    vehicleNo.value = formattedValue;

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

  void submit() {
    Get.back();
  }
}

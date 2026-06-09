import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/core/widgets/custom_snackbar.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'package:skylark/app/data/models/login_response_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';
import 'package:skylark/app/routes/app_routes.dart';

class DashboardController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();
  
  var userData = Rxn<LoginData>();
  final RxList<LocationModel> locations = <LocationModel>[].obs;
  var selectedLocation = Rxn<LocationModel>();
  var isLoadingLocations = false.obs;

  @override
  void onInit() {
    super.onInit();
    getUserData();
    getLocationMasterData();
  }

  void getUserData() {
    userData.value = _storageService.getUser();
  }

  Future<void> getLocationMasterData() async {
    try {
      isLoadingLocations.value = true;
      final userId = userData.value?.userId ?? "";
      final response = await _apiService.get(AppConstants.getLocationMasterDataUrl, queryParameters: {'UserID': userId});
      
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data['data'] is List) {
          data = response.data['data'];
        }
        
        locations.assignAll(data.map((e) => LocationModel.fromJson(e)).toList());
        
        if (locations.length == 1) {
          onLocationChanged(locations[0]);
        } else {
          final savedLocation = _storageService.getLocation();
          if (savedLocation != null) {
            final match = locations.firstWhereOrNull((loc) => loc.locCode == savedLocation.locCode);
            if (match != null) {
              selectedLocation.value = match;
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching locations: $e");
    } finally {
      isLoadingLocations.value = false;
    }
  }



  void onLocationChanged(LocationModel? value) {
    selectedLocation.value = value;
    if (value != null) {
      _storageService.saveLocation(value);
    }
  }

  void navigateToRoute(String route) {
    if (selectedLocation.value == null) {
      CustomSnackbar.show(
        title: 'Location Required',
        message: 'Please select a location first',
        backgroundColor: Colors.orange,
      );
    } else {
      Get.toNamed(route);
    }
  }

  void logout() async {
    await _storageService.clearStorage();
    Get.offAllNamed(AppRoutes.login);
  }
}

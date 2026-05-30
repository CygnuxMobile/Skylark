import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/core/widgets/custom_snackbar.dart';
import 'package:skylark/app/data/models/customer_model.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';

class BookingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final formKey = GlobalKey<FormState>();

  final cnoteController = TextEditingController();
  final ewayBillController = TextEditingController();
  final customerNameController = TextEditingController();
  final originPinController = TextEditingController();
  final destPinController = TextEditingController();
  final consignorController = TextEditingController();
  final consigneeController = TextEditingController();
  final pkgsController = TextEditingController();
  final aWeightController = TextEditingController();
  final invNoController = TextEditingController();
  final invValueController = TextEditingController();

  final lengthController = TextEditingController();
  final breadthController = TextEditingController();
  final heightController = TextEditingController();

  var selectedCustomer = Rxn<CustomerModel>();
  var customers = <CustomerModel>[].obs;
  var isLoadingCustomers = false.obs;
  var customerErrorMessage = ''.obs;

  var locations = <LocationModel>[].obs;
  var isLoadingLocations = false.obs;
  var selectedOrigin = Rxn<LocationModel>();
  var selectedDest = Rxn<LocationModel>();

  var consignees = <CustomerModel>[].obs;
  var isLoadingConsignees = false.obs;
  var selectedConsignee = Rxn<CustomerModel>();

  var isLoadingEwayBill = false.obs;
  var isFieldsReadOnly = false.obs;
  var showDimensions = false.obs;

  @override
  void onInit() {
    super.onInit();
    ewayBillController.addListener(_onEwayBillChanged);
    originPinController.addListener(_onPinChanged);
    destPinController.addListener(_onPinChanged);
    
    // Auto-fill consignor when customer is selected
    ever(selectedCustomer, (value) {
      if (value != null) {
        consignorController.text = "${value.custCode ?? ''} - ${value.custName ?? ''}";
      }
    });

    fetchCustomers();
    fetchLocations();
    fetchConsignees();
  }

  Future<void> fetchLocations() async {
    try {
      isLoadingLocations.value = true;
      final storageService = Get.find<StorageService>();
      final user = storageService.getUser();
      final userId = user?.userId ?? "";
      
      final response = await _apiService.get(
        'Master/GetLocationMasterData',
        queryParameters: {'UserID': userId},
      );

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
      print('Error fetching locations: $e');
    } finally {
      isLoadingLocations.value = false;
    }
  }

  Future<void> fetchConsignees() async {
    try {
      isLoadingConsignees.value = true;
      final response = await _apiService.get(
        AppConstants.getCustomerListUrl,
        queryParameters: {
          'Search': '%',
          'Location': '%',
          'Paybas': 'P02',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['data'] != null && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          consignees.assignAll(data.map((json) => CustomerModel.fromJson(json)).toList());
        }
      }
    } catch (e) {
      print('Error fetching consignees: $e');
    } finally {
      isLoadingConsignees.value = false;
    }
  }

  Future<void> fetchCustomers() async {
    try {
      isLoadingCustomers.value = true;
      final storageService = Get.find<StorageService>();
      final location = storageService.getLocation();
      final locCode = location?.locCode ?? '';

      if (locCode.isEmpty) {
        CustomSnackbar.show(
          title: 'Location Required',
          message: 'Please select a location from the dashboard first.',
          backgroundColor: Colors.orange,
        );
        customers.clear();
        return;
      }

      final response = await _apiService.get(
        AppConstants.getCustomerListUrl,
        queryParameters: {
          'Search': '%',
          'Location': locCode,
          'Paybas': 'P02',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['data'] == null || (responseData['data'] is List && (responseData['data'] as List).isEmpty)) {
          customers.clear();
          customerErrorMessage.value = "No customers found for this location";
        } else {
          customerErrorMessage.value = '';
          final List<dynamic> data = responseData['data'];
          customers.assignAll(data.map((json) => CustomerModel.fromJson(json)).toList());
        }
      }
    } catch (e) {
      print('Error fetching customers: $e');
      customers.clear();
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  void _onEwayBillChanged() {
    if (ewayBillController.text.length == 12) {
      getEwayBillDetails(ewayBillController.text);
    }
  }

  Future<void> getEwayBillDetails(String ewayBillNo) async {
    try {
      isLoadingEwayBill.value = true;
      isFieldsReadOnly.value = false;

      final response = await _apiService.post(
        AppConstants.getEwayBillDetailsUrl,
        data: {
          'lsno': ewayBillNo,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        var details = data;
        if (data is Map && data.containsKey('data')) {
          details = data['data'];
        }

        if (details != null && details is Map) {
          if (details['status'] == 1) {
            final originPin = details['pincode']?.toString() ?? '';
            final destPin = details['toPincode']?.toString() ?? '';
            
            originPinController.text = originPin;
            destPinController.text = destPin;
            
            // Try to find matching locations in the list
            if (locations.isNotEmpty) {
              selectedOrigin.value = locations.firstWhereOrNull((l) => l.locCode == originPin);
              selectedDest.value = locations.firstWhereOrNull((l) => l.locCode == destPin);
            }

            invNoController.text = details['invno']?.toString() ?? '';
            invValueController.text =
                details['eWayInvoicevalue']?.toString() ?? '';
            consignorController.text = details['csgnm']?.toString() ?? '';
            final consigneeName = details['csgenm']?.toString() ?? '';
            consigneeController.text = consigneeName;
            
            // Try to find matching consignee in the list
            if (consignees.isNotEmpty) {
              selectedConsignee.value = consignees.firstWhereOrNull(
                (c) => c.custName?.toLowerCase() == consigneeName.toLowerCase()
              );
            }

            pkgsController.text = details['totalQty']?.toString() ?? '';
            aWeightController.text = details['totalWeight']?.toString() ?? '';
            isFieldsReadOnly.value = true;

            CustomSnackbar.success(
              title: 'Success',
              message: 'E-way bill details fetched successfully',
            );
          } else {
            CustomSnackbar.show(
              title: 'Error',
              message: details['message'] ?? 'Invalid E-way bill details',
              backgroundColor: Colors.orange,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          CustomSnackbar.show(
            title: 'Invalid E-way Bill',
            message: 'No details found for this E-way bill number',
            backgroundColor: Colors.orange,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        CustomSnackbar.error(
          title: 'Error',
          message: 'Something went wrong. Please try again.',
        );
      }
    } catch (e) {
      CustomSnackbar.error(
        title: 'Connection Error',
        message: 'Failed to fetch E-way bill details',
      );
    } finally {
      isLoadingEwayBill.value = false;
    }
  }

  void _onPinChanged() {
    if (originPinController.text == '380001') {
      consignorController.text = 'CONSIGNOR A (Ahmedabad)';
    }
    if (destPinController.text == '400001') {
      consigneeController.text = 'CONSIGNEE B (Mumbai)';
    }
  }

  @override
  void onClose() {
    cnoteController.dispose();
    ewayBillController.dispose();
    customerNameController.dispose();
    originPinController.dispose();
    destPinController.dispose();
    consignorController.dispose();
    consigneeController.dispose();
    pkgsController.dispose();
    aWeightController.dispose();
    invNoController.dispose();
    invValueController.dispose();
    lengthController.dispose();
    breadthController.dispose();
    heightController.dispose();
    super.onClose();
  }

  void submitBooking() {
    if (formKey.currentState!.validate()) {
      CustomSnackbar.success(message: 'Booking submitted successfully');
    }
  }

  void toggleDimensions() {
    showDimensions.value = !showDimensions.value;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/core/widgets/custom_snackbar.dart';
import 'package:skylark/app/data/models/customer_model.dart';
import 'package:skylark/app/data/models/pincode_model.dart';
import 'package:skylark/app/data/models/from_pincode_details_model.dart';
import 'package:skylark/app/data/models/to_pincode_details_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';

import '../../core/values/app_colors.dart';

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

  final cnoteFocus = FocusNode();
  final ewayBillFocus = FocusNode();
  final customerFocus = FocusNode();
  final originFocus = FocusNode();
  final destFocus = FocusNode();
  final consigneeFocus = FocusNode();
  final pkgsFocus = FocusNode();
  final aWeightFocus = FocusNode();
  final invNoFocus = FocusNode();
  final invValueFocus = FocusNode();

  final lengthController = TextEditingController();
  final breadthController = TextEditingController();
  final heightController = TextEditingController();

  var selectedCustomer = Rxn<CustomerModel>();
  var customers = <CustomerModel>[].obs;
  var isLoadingCustomers = false.obs;
  var customerErrorMessage = ''.obs;

  var locations = <PincodeModel>[].obs;
  var isLoadingLocations = false.obs;
  var selectedOrigin = Rxn<PincodeModel>();
  var selectedDest = Rxn<PincodeModel>();
  var selectedOriginDetails = Rxn<FromPincodeDetailsModel>();
  var selectedDestDetails = Rxn<ToPincodeDetailsModel>();

  var consignees = <CustomerModel>[].obs;
  var isLoadingConsignees = false.obs;
  var selectedConsignee = Rxn<CustomerModel>();

  var transportModes = <Map<String, dynamic>>[].obs;
  var selectedTransportMode = Rxn<Map<String, dynamic>>();
  var isLoadingTransportModes = false.obs;

  var isLoadingEwayBill = false.obs;
  var ewayBillErrorMessage = ''.obs;
  var isLoadingFreight = false.obs;
  var isLoadingBooking = false.obs;
  var freightErrorMessage = ''.obs;
  var isFieldsReadOnly = false.obs;
  var showDimensions = false.obs;
  var freightData = <String, dynamic>{}.obs;

  var isValidatingCnote = false.obs;
  var isCnoteValid = true.obs;
  var cnoteValidationMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    ewayBillController.addListener(_onEwayBillChanged);
    cnoteController.addListener(_onCnoteChanged);
    originPinController.addListener(_onPinChanged);
    destPinController.addListener(_onPinChanged);

    ever(selectedCustomer, (value) {
      if (value != null) {
        consignorController.text = "${value.custCode ?? ''} - ${value.custName ?? ''}";
        fetchTransportModes(value.custCode ?? '');
      } else {
        transportModes.clear();
        selectedTransportMode.value = null;
      }
    });

    fetchCustomers();
  }

  Future<void> fetchTransportModes(String custCode) async {
    try {
      isLoadingTransportModes.value = true;
      final response = await _apiService.get(
        AppConstants.getTransportModeUrl,
        queryParameters: {
          'Custcode': custCode,
          'Paybas': 'P02',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data['data'] is List) {
          data = response.data['data'];
        }
        transportModes.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
        
        // Auto-select first if available
        if (transportModes.isNotEmpty) {
          selectedTransportMode.value = transportModes[0];
        }
      }
    } catch (e) {
      print('Error fetching transport modes: $e');
    } finally {
      isLoadingTransportModes.value = false;
    }
  }

  Future<void> fetchPincodes(String query) async {
    try {
      isLoadingLocations.value = true;

      final response = await _apiService.get(
        AppConstants.getPincodeUrl,
        queryParameters: {'search': query.isEmpty ? '%%%' : query},
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data['data'] is List) {
          data = response.data['data'];
        }
        locations.assignAll(data.map((e) => PincodeModel.fromJson(e)).toList());
      }
    } catch (e) {
      print('Error fetching pincodes: $e');
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
    } else {
      ewayBillErrorMessage.value = '';
    }
  }

  void _onCnoteChanged() {
    final text = cnoteController.text.trim();
    if (text.length >= 4) {
      debounce(_dummyRx, (_) => validateDocketSeries(text), time: 500.milliseconds);
      _dummyRx.value = text;
    } else {
      isCnoteValid.value = true;
      cnoteValidationMessage.value = "";
    }
  }

  final _dummyRx = "".obs;

  Future<void> validateDocketSeries(String docketNo) async {
    try {
      isValidatingCnote.value = true;
      final storageService = Get.find<StorageService>();
      final user = storageService.getUser();
      final location = storageService.getLocation();

      final response = await _apiService.get(
        AppConstants.validateDocketSeriesUrl,
        queryParameters: {
          'DocketNo': docketNo,
          'LocCode': location?.locCode ?? "",
          'UserId': user?.userId ?? "",
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          final result = data[0];
          final String codeId = result['codeId']?.toString() ?? "0";
          final String codeDesc = result['codeDesc']?.toString() ?? "";

          if (codeId == "1") {
            isCnoteValid.value = true;
            cnoteValidationMessage.value = "Valid Series";
          } else {
            isCnoteValid.value = false;
            cnoteValidationMessage.value = codeDesc.isNotEmpty ? codeDesc : "Invalid Series";
          }
        }
      }
    } catch (e) {
      print('Error validating docket series: $e');
    } finally {
      isValidatingCnote.value = false;
    }
  }

  Future<void> getEwayBillDetails(String ewayBillNo) async {
    try {
      isLoadingEwayBill.value = true;
      isFieldsReadOnly.value = false;
      ewayBillErrorMessage.value = '';

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

            if (locations.isNotEmpty) {
              selectedOrigin.value = locations.firstWhereOrNull((l) => l.pincode == originPin);
              selectedDest.value = locations.firstWhereOrNull((l) => l.pincode == destPin);
            }

            invNoController.text = details['invno']?.toString() ?? '';
            invValueController.text =
                details['eWayInvoicevalue']?.toString() ?? '';
            consignorController.text = details['csgnm']?.toString() ?? '';
            final consigneeName = details['csgenm']?.toString() ?? '';
            consigneeController.text = consigneeName;

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
            ewayBillErrorMessage.value = details['message'] ?? 'Invalid E-way bill details';
            CustomSnackbar.show(
              title: 'Error',
              message: ewayBillErrorMessage.value,
              backgroundColor: Colors.orange,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          ewayBillErrorMessage.value = 'No details found for this E-way bill number';
          CustomSnackbar.show(
            title: 'Invalid E-way Bill',
            message: ewayBillErrorMessage.value,
            backgroundColor: Colors.orange,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        ewayBillErrorMessage.value = 'Something went wrong. Please try again.';
        CustomSnackbar.error(
          title: 'Error',
          message: ewayBillErrorMessage.value,
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

    cnoteFocus.dispose();
    ewayBillFocus.dispose();
    customerFocus.dispose();
    originFocus.dispose();
    destFocus.dispose();
    consigneeFocus.dispose();
    pkgsFocus.dispose();
    aWeightFocus.dispose();
    invNoFocus.dispose();
    invValueFocus.dispose();
    super.onClose();
  }

  void submitBooking() async {
    if (formKey.currentState!.validate()) {
      if (cnoteController.text.isNotEmpty && !isCnoteValid.value) {
        cnoteFocus.requestFocus();
        CustomSnackbar.error(
          title: 'Cnote Error',
          message: cnoteValidationMessage.value.isNotEmpty ? cnoteValidationMessage.value : 'Invalid Cnote Series',
        );
        return;
      }

      if (ewayBillErrorMessage.value.isNotEmpty) {
        ewayBillFocus.requestFocus();
        CustomSnackbar.error(
          title: 'E-way Bill Error',
          message: ewayBillErrorMessage.value,
        );
        return;
      }

      await fetchContractFreight();
      if (freightErrorMessage.value.isNotEmpty) {
        invNoFocus.requestFocus();
      } else {
        await docketSubmit();
      }
    } else {
      if (selectedCustomer.value == null) {
        customerFocus.requestFocus();
      } else if (selectedOrigin.value == null) {
        originFocus.requestFocus();
      } else if (selectedDest.value == null) {
        destFocus.requestFocus();
      } else if (selectedConsignee.value == null) {
        consigneeFocus.requestFocus();
      } else if (pkgsController.text.isEmpty) {
        pkgsFocus.requestFocus();
      } else if (aWeightController.text.isEmpty) {
        aWeightFocus.requestFocus();
      } else if (invNoController.text.isEmpty) {
        invNoFocus.requestFocus();
      } else if (invValueController.text.isEmpty) {
        invValueFocus.requestFocus();
      }
    }
  }

  void toggleDimensions() {
    showDimensions.value = !showDimensions.value;
  }

  void onOriginSelected(PincodeModel? value) {
    if (value != null && value.pincode == selectedDest.value?.pincode) {
      Future.delayed(const Duration(milliseconds: 300), () {
        CustomSnackbar.show(
          title: 'Selection Error',
          message: 'Origin and Destination pincode cannot be same',
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }
    selectedOrigin.value = value;
    if (value != null) {
      originPinController.text = value.pincode ?? '';
      fetchFromPincodeDetails(value.pincode ?? '');
    }
  }

  Future<void> fetchFromPincodeDetails(String pincode) async {
    try {
      final response = await _apiService.get(
        AppConstants.getFromPincodeDetailsUrl,
        queryParameters: {'FromPincode': pincode},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          selectedOriginDetails.value = FromPincodeDetailsModel.fromJson(data[0]);
          print('Origin Details Saved: ${selectedOriginDetails.value?.fromCity}');
        }
      }
    } catch (e) {
      print('Error fetching from pincode details: $e');
    }
  }

  void onDestSelected(PincodeModel? value) {
    if (value != null && value.pincode == selectedOrigin.value?.pincode) {
      Future.delayed(const Duration(milliseconds: 300), () {
        CustomSnackbar.show(
          title: 'Selection Error',
          message: 'Origin and Destination pincode cannot be same',
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }
    selectedDest.value = value;
    if (value != null) {
      destPinController.text = value.pincode ?? '';
      fetchToPincodeDetails(value.pincode ?? '');
      fetchConsigneesByPincode(value.pincode ?? '');
    }
  }

  Future<void> fetchConsigneesByPincode(String pincode) async {
    try {
      final customerCode = selectedCustomer.value?.custCode ?? '';
      isLoadingConsignees.value = true;

      final response = await _apiService.get(
        AppConstants.getConsigneeUrl,
        queryParameters: {
          'Customer': customerCode,
          'Pincode': pincode,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        consignees.assignAll(data.map((json) => CustomerModel.fromJson(json)).toList());
      }
    } catch (e) {
      print('Error fetching consignees by pincode: $e');
    } finally {
      isLoadingConsignees.value = false;
    }
  }

  Future<void> fetchToPincodeDetails(String pincode) async {
    try {
      final customerCode = selectedCustomer.value?.custCode ?? '';

      final response = await _apiService.get(
        AppConstants.getToPincodeDetailsUrl,
        queryParameters: {
          'ToPincode': pincode,
          'Party_Code': customerCode,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          selectedDestDetails.value = ToPincodeDetailsModel.fromJson(data[0]);
          print('Destination Details Saved: ${selectedDestDetails.value?.toCity}');
        }
      }
    } catch (e) {
      print('Error fetching to pincode details: $e');
    }
  }

  Future<void> fetchContractFreight() async {
    try {
      isLoadingFreight.value = true;
      freightErrorMessage.value = '';
      freightData.clear();

      final origin = selectedOriginDetails.value;
      final dest = selectedDestDetails.value;

      if (origin == null || dest == null) {
        CustomSnackbar.error(
          title: 'Missing Data',
          message: 'Please select Origin and Destination pincodes first',
        );
        return;
      }

      final body = {
        "Frompincode": selectedOrigin.value?.pincode ?? "",
        "topincode": selectedDest.value?.pincode ?? "",
        "ContractID": selectedCustomer.value?.contractId ?? "",
        "FlagProceed": "P",
        "Depth": "CLRMSP",
        "PayBase": "P02",
        "FromCity": origin.fromCity ?? "",
        "Fromstate": origin.orgNstnm ?? "",
        "Tostate": dest.desTstnm ?? "",
        "ToCity": dest.toCity ?? "",
        "OrgnLoc": origin.orgncd ?? "",
        "DelLoc": dest.destcd ?? "",
        "ServiceType": 1,
        "FTLType": "",
        "TransMode": selectedTransportMode.value?['codeId']?.toString() ?? dest.transType ?? "",
        "ChargedWeight": aWeightController.text,
        "NoOfPkgs": pkgsController.text,
        "OrderID": selectedCustomer.value?.contractId ?? "",
        "InvAmt": invValueController.text
      };

      final response = await _apiService.post(
        AppConstants.getContractFreightUrl,
        data: body,
      );

      final responseData = response.data;
      if (response.statusCode == 200 && responseData['statusCode'] != 400) {
        freightErrorMessage.value = '';
        if (responseData['data'] != null) {
          if (responseData['data'] is List && (responseData['data'] as List).isNotEmpty) {
            freightData.value = responseData['data'][0];
          } else if (responseData['data'] is Map) {
            freightData.value = responseData['data'];
          }
        }
        print('Freight details fetched successfully');
      } else {
        final errorData = responseData['errors'];
        final message = errorData?['message'] ?? '';
        freightErrorMessage.value = message;
      }
    } catch (e) {
      print('Error fetching contract freight: $e');
      if (e is dio.DioException) {
        final errorMsg = e.response?.data['errors']?['message'] ?? '';
        freightErrorMessage.value = errorMsg;
      }
    } finally {
      isLoadingFreight.value = false;
    }
  }

  Future<void> docketSubmit() async {
    try {
      isLoadingBooking.value = true;
      final storageService = Get.find<StorageService>();
      final user = storageService.getUser();

      final origin = selectedOriginDetails.value;
      final dest = selectedDestDetails.value;

      final Map<String, dynamic> docket = {
        "dockno": cnoteController.text,
        "dockdt": DateTime.now().toIso8601String(),
        "manual_dockno": cnoteController.text,
        "ewayBillNo": ewayBillController.text,
        "partY_CODE": selectedCustomer.value?.custCode ?? "",
        "frompincode": selectedOrigin.value?.pincode ?? "",
        "topincode": selectedDest.value?.pincode ?? "",
        "pkgsno": int.tryParse(pkgsController.text) ?? 0,
        "actuwt": double.tryParse(aWeightController.text) ?? 0,
        "reassigN_DESTCD": dest?.destcd ?? "",
        "csgncd": selectedCustomer.value?.custCode ?? "",
        "csgnnm": selectedCustomer.value?.custName ?? "",
        "csgecd": selectedConsignee.value?.custCode ?? "",
        "csgenm": selectedConsignee.value?.custName ?? "",
        "fromCity": origin?.fromCity ?? "",
        "orgncd": origin?.orgncd ?? "",
        "orgNstnm": origin?.orgNstnm ?? "",
        "orgnArea": origin?.orgnArea ?? "",
        "toCity": dest?.toCity ?? "",
        "destcd": dest?.destcd ?? "",
        "desTstnm": dest?.desTstnm ?? "",
        "destArea": dest?.destArea ?? "",
        "pkp_dly": dest?.pkpDly ?? "",
        "trans_type": selectedTransportMode.value?['codeId']?.toString() ?? dest?.transType ?? "",
        "service_type": dest?.serviceType ?? "",
        "pkgsty": dest?.pkgsty ?? "",
        "businesstype": dest?.businesstype ?? "",
        "contractID": selectedCustomer.value?.contractId ?? "",
        "freightCharge": freightData['freightCharge'] ?? 0,
        "freightRate": freightData['freightRate'] ?? 0,
        "rateType": freightData['rateType'] ?? "",
        "trDays": freightData['trDays'] ?? 0,
        "invoiceRateApplay": "0",
        "invoiceRate": 0,
        "billingState": origin?.orgNstnm ?? "",
        "serviceType": dest?.serviceType ?? "1",
        "ftlType": dest?.businesstype ?? "1",
        "transMode": selectedTransportMode.value?['codeId']?.toString() ?? dest?.transType ?? "5",
        "chargedWeight": double.tryParse(aWeightController.text) ?? 0,
        "noOfPkgs": int.tryParse(pkgsController.text) ?? 0,
        "acT_WT": double.tryParse(aWeightController.text) ?? 0,
        "orderID": selectedCustomer.value?.contractId ?? "",
        "invAmt": double.tryParse(invValueController.text) ?? 0,
        "invNo": invNoController.text,
        "CompanyCode": user?.baseCompanyCode ?? ""
      };

      final List<Map<String, dynamic>> invoices = [
        {
          "voL_L": double.tryParse(lengthController.text) ?? 0,
          "voL_B": double.tryParse(breadthController.text) ?? 0,
          "voL_H": double.tryParse(heightController.text) ?? 0
        }
      ];

      final body = {
        "docket": docket,
        "invoices": invoices
      };

      final response = await _apiService.post(
        AppConstants.docketSubmitUrl,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['statusCode'] == 200) {
          final dockno = data['data']['dockno'];
          _showSuccessDialog(dockno);
        } else {
          CustomSnackbar.error(
              title: "Submission Failed",
              message: data['message'] ?? "Failed to submit booking"
          );
        }
      }
    } catch (e) {
      print('Error submitting docket: $e');
      CustomSnackbar.error(
          title: "Error",
          message: "An error occurred during submission"
      );
    } finally {
      isLoadingBooking.value = false;
    }
  }

  void _showSuccessDialog(String dockNo) {
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
                'Docket generated successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      dockNo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
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
}

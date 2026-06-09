import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'package:skylark/app/data/models/special_cost_voucher_request_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/values/app_constants.dart';

class ExpenseController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  var selectedBranch = Rxn<LocationModel>();
  var selectedDate = DateTime.now().obs;
  final totalKmController = TextEditingController();
  final floorController = TextEditingController();
  final paidToController = TextEditingController();
  var selectedCategory = RxnString();
  final accountSearchController = TextEditingController();
  var selectedAccount = Rxn<Map<String, dynamic>>();
  final againstController = TextEditingController();
  var selectedDocType = 'DKT'.obs;
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  var selectedPaymentMode = 'Cash'.obs;
  final remarksController = TextEditingController();
  var isSubmitting = false.obs;
  var isValidatingDoc = false.obs;
  var isDocValid = false.obs;
  var docValidationMessage = "".obs;

  var frontDocument = "".obs;
  var backDocument = "".obs;
  var frontFileName = "".obs;
  var backFileName = "".obs;
  var isPickingImage = false.obs;

  final List<String> categories = ['Delivery Expense', 'Office Maintenance', 'Fuel', 'Stationery', 'Other'];
  final List<String> paymentModes = ['Cash', 'Bank Transfer', 'Cheque', 'UPI'];
  final Map<String, String> docTypes = {'Docket': 'DKT', 'PRS': 'PRS'};

  final RxList<LocationModel> locations = <LocationModel>[].obs;
  var isLoadingLocations = false.obs;

  final RxList<Map<String, dynamic>> accounts = <Map<String, dynamic>>[].obs;
  var isLoadingAccounts = false.obs;

  @override
  void onInit() {
    super.onInit();
    final savedLocation = _storageService.getLocation();
    if (savedLocation != null) {
      selectedBranch.value = savedLocation;
    }
    getLocationMasterData();
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

        if (selectedBranch.value == null && locations.isNotEmpty) {
          selectedBranch.value = locations[0];
        }
      }
    } catch (e) {
      debugPrint("Error fetching locations: $e");
    } finally {
      isLoadingLocations.value = false;
    }
  }

  Future<void> searchAccounts(String query) async {
    if (query.isEmpty) {
      accounts.clear();
      return;
    }
    try {
      isLoadingAccounts.value = true;
      final response = await _apiService.get(AppConstants.getAccountCodeListUrl, queryParameters: {'search': query});

      if (response.data != null) {
        List<dynamic> rawData = [];
        if (response.data is List) {
          rawData = response.data;
        } else if (response.data['data'] is List) {
          rawData = response.data['data'];
        }

        final List<Map<String, dynamic>> fetchedAccounts = rawData.map((e) => Map<String, dynamic>.from(e)).toList();
        accounts.assignAll(fetchedAccounts);
        debugPrint("Fetched ${accounts.length} accounts for query: $query");
      }
    } catch (e) {
      debugPrint("Error searching accounts: $e");
    } finally {
      isLoadingAccounts.value = false;
    }
  }

  Future<void> validateDocument(String docNo) async {
    if (docNo.isEmpty) {
      isDocValid.value = false;
      docValidationMessage.value = "";
      return;
    }

    try {
      isValidatingDoc.value = true;
      final response = await _apiService.get(AppConstants.validateDocumentUrl, queryParameters: {'docNo': docNo, 'docType': selectedDocType.value});

      if (response.data != null) {
        final status = response.data['status'];
        if (status == 200) {
          isDocValid.value = true;
          docValidationMessage.value = response.data['message'] ?? "Valid Document";
        } else {
          isDocValid.value = false;
          if (response.data['errors'] != null && response.data['errors']['message'] != null) {
            docValidationMessage.value = response.data['errors']['message'];
          } else {
            docValidationMessage.value = response.data['message'] ?? "Invalid Document";
          }
        }
      } else {
        isDocValid.value = false;
        docValidationMessage.value = "Validation failed";
      }
    } catch (e) {
      debugPrint("Error validating document: $e");
      isDocValid.value = false;
      docValidationMessage.value = "Error validating document";
    } finally {
      isValidatingDoc.value = false;
    }
  }

  Future<void> pickDocument(bool isFront, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50, // This helps in compression to keep it around 1MB
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final int fileSizeInBytes = await file.length();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5) {
          Get.snackbar("File too large", "Please select a file smaller than 5MB", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }

        final List<int> imageBytes = await file.readAsBytes();
        final String base64Image = base64Encode(imageBytes);

        if (isFront) {
          frontDocument.value = base64Image;
          frontFileName.value = pickedFile.name;
        } else {
          backDocument.value = base64Image;
          backFileName.value = pickedFile.name;
        }
      }
    } catch (e) {
      debugPrint("Error picking document: $e");
    }
  }

  void removeDocument(bool isFront) {
    if (isFront) {
      frontDocument.value = "";
      frontFileName.value = "";
    } else {
      backDocument.value = "";
      backFileName.value = "";
    }
  }

  Future<void> saveExpense() async {
    if (amountController.text.isEmpty) {
      Get.snackbar("Error", "Please enter amount", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedAccount.value == null) {
      Get.snackbar("Error", "Please select an account code", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSubmitting.value = true;
      final user = _storageService.getUser();
      final location = selectedBranch.value;

      final request = SpecialCostVoucherRequest(
        voucherData: VoucherData(
          financialYear: user?.finYear ?? "",
          voucherDate: selectedDate.value,
          entryBy: user?.userId ?? "",
          baseLocationCode: location?.locCode ?? "",
          companyCode: user?.baseCompanyCode ?? "",
          accountingLocation: location?.locCode ?? "",
          preparedatlocation: location?.locCode ?? "",
          custTyp: "O",
          custCode: "8888",
          customerName: paidToController.text,
          narration: remarksController.text,
          manualNo: againstController.text,
          referenceNo: "",
          preparedFor: "",
          gstType: "N",
          panNumber: "0",
          hEducationCess: "0",
          educationCess: "false",
          isServicetaxapply: true,
          serviceTaxRegNo: "0",
          hdnServiceTaxRate: 0,
          serviceTax: 0,
          isTdStaxapply: false,
          tdsSection: "",
          tdsRate: 0,
          tdsAmount: 0,
          totalKm: int.tryParse(totalKmController.text) ?? 0,
          floor: floorController.text,
          frontDocument: frontDocument.value,
          backDocument: backDocument.value,
        ),
        scVoucher: [
          ScVoucher(
            accountCode: selectedAccount.value?['acccode'] ?? "",
            amount: amountController.text,
            narrationAccountinfo: descriptionController.text,
            docNo: againstController.text,
            docType: selectedDocType.value,
          ),
        ],
        paymentMode: [
          PaymentMode(
            paymentMode: selectedPaymentMode.value.toUpperCase(),
            transactionMode: "PAYMENT",
            netamount: double.tryParse(amountController.text) ?? 0,
            cashAmount: selectedPaymentMode.value.toUpperCase() == "CASH" ? (double.tryParse(amountController.text) ?? 0) : 0,
            chequeAmount: selectedPaymentMode.value.toUpperCase() == "CHEQUE" ? (double.tryParse(amountController.text) ?? 0) : 0,
            chequeNo: "",
            chequedate: selectedDate.value,
            cashAccount: "Cash In Hand - HO / RO / BRANCH",
            depositedInBank: "",
            receivedFromBank: "",
            businessDivision: "",
            custTyp: "O",
          ),
        ],
        gstCharges: [GstCharge(chargeCode: "", percentage: 0, chargeAmount: 0, accountReceivable: "", accountPayable: "")],
        tdsInfo: TdsInfo(isTdsEnabled: false, tdsRate: 0, tdsAmount: 0, tdsAcccode: ""),
      );

      final response = await _apiService.post(AppConstants.specialCostVoucherSubmitUrl, data: request.toJson());

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        final int apiStatusCode = resData['statusCode'] ?? resData['status'] ?? 0;

        if (apiStatusCode == 200) {
          String voucherNo = "";
          if (resData['data'] != null) {
            if (resData['data'] is Map) {
              voucherNo = (resData['data']['voucherNo'] ?? resData['data']['voucherno'] ?? resData['data']['VoucherNo'] ?? "").toString();
            } else {
              voucherNo = resData['data'].toString();
            }
          }

          if (voucherNo.isEmpty) {
            voucherNo = (resData['voucherNo'] ?? resData['voucherno'] ?? resData['VoucherNo'] ?? "").toString();
          }

          _showSuccessDialog(voucherNo);

          // Clear fields
          amountController.clear();
          descriptionController.clear();
          paidToController.clear();
          remarksController.clear();
          againstController.clear();
          totalKmController.clear();
          selectedDocType.value = 'DKT';
          floorController.clear();
          selectedCategory.value = null;
          selectedPaymentMode.value = 'Cash';
          selectedAccount.value = null;
          accountSearchController.clear();
          frontDocument.value = "";
          backDocument.value = "";
          frontFileName.value = "";
          backFileName.value = "";
        } else {
          // Handle API level error even if HTTP status is 200
          String errorMsg = "Failed to save expense";
          if (resData['errors'] != null && resData['errors']['message'] != null) {
            errorMsg = resData['errors']['message'];
          } else if (resData['message'] != null) {
            errorMsg = resData['message'];
          }
          Get.snackbar("Error", errorMsg, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
        }
      } else {
        Get.snackbar("Error", response.data?['message'] ?? "Failed to save expense", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error saving expense: $e");
      Get.snackbar("Error", "An error occurred while saving expense", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showSuccessDialog(String voucherNo) {
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
                'Expense saved successfully',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (voucherNo.isNotEmpty) ...[
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
                        'Voucher No: ',
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                      ),
                      Text(
                        voucherNo,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ],
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

  @override
  void onClose() {
    totalKmController.dispose();
    floorController.dispose();
    paidToController.dispose();
    againstController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    remarksController.dispose();
    super.onClose();
  }
}

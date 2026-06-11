import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';

class PODUploadController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();

  var isLoading = false.obs;
  final RxList<dynamic> podList = <dynamic>[].obs;

  var fromDate = DateTime.now().subtract(const Duration(days: 7)).obs;
  var toDate = DateTime.now().obs;

  var frontImage = Rxn<File>();
  var backImage = Rxn<File>();
  var isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPODList();
  }

  Future<void> fetchPODList() async {
    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      final location = _storageService.getLocation();
      
      final String fromDateStr = DateFormat('dd MMM yyyy').format(fromDate.value);
      final String toDateStr = DateFormat('dd MMM yyyy').format(toDate.value);

      final body = {
        "brcd": location?.locCode ?? "",
        "userName": user?.userId ?? "",
        "companyCode": user?.baseCompanyCode ?? "",
        "fromDate": fromDateStr,
        "toDate": toDateStr,
        "gcNo": ""
      };

      final response = await _apiService.post(
        AppConstants.getPODListUrl,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['data'] != null && responseData['data'] is Map) {
          final dataMap = responseData['data'] as Map;
          if (dataMap['pod'] != null && dataMap['pod'] is List) {
            podList.assignAll(dataMap['pod']);
          } else {
            podList.clear();
          }
        } else if (responseData['data'] != null && responseData['data'] is List) {
          podList.assignAll(responseData['data']);
        } else {
          podList.clear();
        }
      }
    } catch (e) {
      _logger.e("Error fetching POD list: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != fromDate.value) {
      fromDate.value = picked;
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != toDate.value) {
      toDate.value = picked;
    }
  }

  Future<void> pickImage(bool isFront, ImageSource source, String docketNo) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 50,
      preferredCameraDevice: CameraDevice.rear,
    );
    
    if (image != null) {
      try {
        final user = _storageService.getUser();
        final userName = user?.userId ?? "user";
        
        String extension = path.extension(image.path);
        if (extension.isEmpty) extension = ".jpg";
        String newName = 'POD@$docketNo@$userName@${isFront ? "1" : "2"}$extension';
        
        final String dirPath = path.dirname(image.path);
        final String newPath = path.join(dirPath, newName);
        
        final File renamedFile = await File(image.path).rename(newPath);
        
        if (isFront) {
          frontImage.value = renamedFile;
        } else {
          backImage.value = renamedFile;
        }
        _logger.i("Image saved as: $newName");
      } catch (e) {
        _logger.e("Error renaming image: $e");
        if (isFront) {
          frontImage.value = File(image.path);
        } else {
          backImage.value = File(image.path);
        }
      }
    }
  }

  void clearImages() {
    frontImage.value = null;
    backImage.value = null;
  }

  Future<void> submitPOD(String gcNo) async {
    _logger.i("Submit POD called for GC No: $gcNo");
    if (frontImage.value == null && backImage.value == null) {
      Get.snackbar("Error", "Please select at least one image", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isUploading.value = true;
      
      _logger.i("📤 SUBMIT POD REQUEST - GC No: $gcNo");
      
      final formData = dio.FormData();
      
      if (frontImage.value != null) {

        formData.files.add(MapEntry(
          'PODImage',
          await dio.MultipartFile.fromFile(
            frontImage.value!.path,
            filename: path.basename(frontImage.value!.path),
          ),
        ));
      }
      
      if (backImage.value != null) {
        formData.files.add(MapEntry(
          'PODImageBack',
          await dio.MultipartFile.fromFile(
            backImage.value!.path,
            filename: path.basename(backImage.value!.path),
          ),
        ));
      }

      final response = await _apiService.post(
        AppConstants.uploadPODImageUrl,
        data: formData,
      );

      _logger.i("✅ SUBMIT POD SUCCESS - GC No: $gcNo - Response: ${response.data}");
      
      Get.back();
      Get.snackbar("Success", "POD uploaded successfully for $gcNo", backgroundColor: Colors.green, colorText: Colors.white);
      clearImages();
      fetchPODList();
    } catch (e) {
      _logger.e("❌ SUBMIT POD ERROR - GC No: $gcNo\nError: $e");
      String errorMessage = "Failed to upload POD";
      if (e is dio.DioException) {
        errorMessage = e.response?.data?['message'] ?? errorMessage;
      }
      Get.snackbar("Error", errorMessage, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isUploading.value = false;
    }
  }
}

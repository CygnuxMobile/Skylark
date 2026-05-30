import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrsClosureController extends GetxController {
  final drsNoController = TextEditingController(text: "DS/GUR/25/0001");
  final vendorNameController = TextEditingController(text: "Porter");
  final freightAmtController = TextEditingController(text: "2000");
  final otherAmtController = TextEditingController(text: "200");
  final finalBalController = TextEditingController(text: "2200");

  @override
  void onInit() {
    super.onInit();
    freightAmtController.addListener(_calculateFinalBalance);
    otherAmtController.addListener(_calculateFinalBalance);
  }

  void _calculateFinalBalance() {
    double freight = double.tryParse(freightAmtController.text) ?? 0;
    double other = double.tryParse(otherAmtController.text) ?? 0;
    finalBalController.text = (freight + other).toStringAsFixed(0);
  }

  void submit() {
    Get.snackbar("Success", "DRS Closed Successfully");
    Get.back();
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

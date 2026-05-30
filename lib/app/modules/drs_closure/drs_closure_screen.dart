import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import 'drs_closure_controller.dart';

class DrsClosureScreen extends GetView<DrsClosureController> {
  const DrsClosureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DRS Closure', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("DRS No"),
                CustomTextField(
                  controller: controller.drsNoController,
                  readOnly: true,
                ),
                const SizedBox(height: 15),

                _buildLabel("Vendor Name"),
                CustomTextField(
                  controller: controller.vendorNameController,
                ),
                const SizedBox(height: 15),

                _buildLabel("Freight Amt"),
                CustomTextField(
                  controller: controller.freightAmtController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),

                _buildLabel("Other Amt"),
                CustomTextField(
                  controller: controller.otherAmtController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),

                _buildLabel("Final Bal"),
                CustomTextField(
                  controller: controller.finalBalController,
                  readOnly: true,
                ),
                const SizedBox(height: 30),

                Center(
                  child: CustomButton(
                    text: "SUBMIT",
                    onPressed: controller.submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'package:skylark/app/core/widgets/custom_search_dropdown.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import '../prs_closure_controller.dart';

class PrsClosureDetailScreen extends GetView<PrsClosureController> {
  const PrsClosureDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('PRS Closure Detail', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("PRS No"),
            CustomTextField(
              controller: controller.prsNoController,
              readOnly: true,
              enabled: false,
            ),
            const SizedBox(height: 15),

            _buildLabel("Vendor Name"),
            Obx(() => CustomSearchDropdown<dynamic>(
              items: controller.vendorList,
              hintText: "Select Vendor",
              isLoading: controller.isLoadingVendors.value,
              selectedItem: controller.selectedVendor.value,
              itemAsString: (item) => item['vendor_Name'] ?? item['vendorname'] ?? "",
              onSelected: (val) {
                controller.selectedVendor.value = val;
                if (val != null) {
                  controller.vendorNameController.text = val['vendor_Name'] ?? val['vendorname'] ?? "";
                }
              },
            )),
            const SizedBox(height: 15),

            Obx(() => controller.selectedVendorType.value == '01' 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      enabled: false,
                    ),
                    const SizedBox(height: 15),
                  ],
                ) 
              : const SizedBox.shrink()),

            const SizedBox(height: 15),

            Obx(() => Center(
              child: CustomButton(
                text: "SUBMIT",
                isLoading: controller.isLoading.value,
                onPressed: () => controller.submit(),
              ),
            )),
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
          fontSize: 15,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }
}

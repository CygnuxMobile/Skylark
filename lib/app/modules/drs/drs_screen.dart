import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'package:skylark/app/core/widgets/custom_search_dropdown.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import 'drs_controller.dart';

class DrsScreen extends GetView<DrsController> {
  const DrsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DRS Generation', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Vendor Type"),
            CustomSearchDropdown(
              items: controller.vendorTypes,
              hintText: "Select Vendor Type",
              onSelected: controller.onVendorTypeChanged,
            ),
            const SizedBox(height: 15),

            _buildLabel("Vehicle No"),
            Obx(() => controller.isOwnVehicle.value
                ? CustomSearchDropdown(
                    items: controller.vehicles,
                    hintText: "Select Vehicle No",
                    onSelected: (val) => controller.vehicleNo.value = val ?? '',
                  )
                : CustomTextField(
                    hintText: "Enter Vehicle No",
                    onChanged: (val) => controller.vehicleNo.value = val,
                  )),
            const SizedBox(height: 15),

            _buildLabel("TRIPSHEET/ Amount"),
            Obx(() => controller.isOwnVehicle.value
                ? CustomSearchDropdown(
                    items: controller.tripSheets,
                    hintText: "Select Trip Sheet",
                    onSelected: (val) => controller.tripSheet.value = val ?? '',
                  )
                : CustomTextField(
                    hintText: "Enter Trip Sheet/Amount",
                    onChanged: (val) => controller.tripSheet.value = val,
                  )),
            const SizedBox(height: 15),

            _buildLabel("Start KM"),
            CustomTextField(
              hintText: "Enter Start KM",
              keyboardType: TextInputType.number,
              onChanged: (val) => controller.startKm.value = val,
            ),
            const SizedBox(height: 15),

            _buildLabel("Cnote No"),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: controller.cNoteNumbers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      controller.cNoteNumbers[index],
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
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

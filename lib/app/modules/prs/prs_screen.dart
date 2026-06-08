import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'package:skylark/app/core/widgets/custom_search_dropdown.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'prs_controller.dart';

class PrsScreen extends GetView<PrsController> {
  const PrsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PRS Generation',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Origin"),
            Obx(
              () => CustomSearchDropdown<LocationModel>(
                items: controller.locations,
                hintText: "Select Origin",
                onSelected: controller.onOriginLocationChanged,
                itemAsString: (item) =>
                    "${item.locName ?? ''} (${item.locCode ?? ''})",
                selectedItem: controller.selectedOrigin.value,
                isLoading: controller.isLoadingLocations.value,
                compareFn: (item, selectedItem) =>
                    item.locCode == selectedItem.locCode,
              ),
            ),
            const SizedBox(height: 15),

            _buildLabel("Location"),
            Obx(
              () => CustomSearchDropdown<LocationModel>(
                items: controller.locations,
                hintText: "Select Location",
                onSelected: controller.onLocationChanged,
                itemAsString: (item) =>
                    "${item.locName ?? ''} (${item.locCode ?? ''})",
                selectedItem: controller.selectedLocation.value,
                isLoading: controller.isLoadingLocations.value,
                compareFn: (item, selectedItem) =>
                    item.locCode == selectedItem.locCode,
              ),
            ),
            const SizedBox(height: 15),

            Obx(
              () => Visibility(
                visible: !controller.isLocalLocation.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Co-loader"),
                    Obx(
                      () => CustomSearchDropdown(
                        items: controller.coLoaders,
                        hintText: "Select Co-loader",
                        selectedItem: controller.selectedCoLoader.value.isEmpty
                            ? null
                            : controller.selectedCoLoader.value,
                        onSelected: (val) =>
                            controller.selectedCoLoader.value = val ?? '',
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),

            _buildLabel("Vendor Type"),
            Obx(
              () => CustomSearchDropdown(
                items: controller.vendorTypes,
                hintText: "Select Vendor Type",
                selectedItem: controller.selectedVendorType.value.isEmpty
                    ? null
                    : controller.selectedVendorType.value,
                onSelected: controller.onVendorTypeChanged,
              ),
            ),
            const SizedBox(height: 15),

            _buildLabel("Vehicle No"),
            Obx(
              () => controller.isOwnVehicle.value
                  ? CustomSearchDropdown<String>(
                      items: controller.vehicles,
                      hintText: "Select Vehicle No",
                      isLoading: controller.isLoadingVehicles.value,
                      selectedItem: controller.vehicleNo.value.isEmpty
                          ? null
                          : controller.vehicleNo.value,
                      onSelected: (val) =>
                          controller.onVehicleNoChanged(val ?? ''),
                    )
                  : CustomTextField(
                      controller: controller.vehicleNoController,
                      hintText: "Enter Vehicle No",
                      onChanged: (val) => controller.onVehicleNoChanged(val),
                    ),
            ),
            const SizedBox(height: 15),

            Obx(
              () => Visibility(
                visible: controller.isOwnVehicle.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("TRIPSHEET"),
                    CustomSearchDropdown(
                      items: controller.tripSheets,
                      hintText: "Select Trip Sheet",
                      isLoading: controller.isLoadingTripSheets.value,
                      selectedItem: controller.tripSheet.value.isEmpty
                          ? null
                          : controller.tripSheet.value,
                      onSelected: (val) =>
                          controller.tripSheet.value = val ?? '',
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),

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
              child: CustomButton(text: "SUBMIT", onPressed: controller.submit),
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

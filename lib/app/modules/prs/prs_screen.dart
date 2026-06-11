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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                        items: controller.allLocations,
                        hintText: "Select Location",
                        onSelected: controller.onLocationChanged,
                        itemAsString: (item) =>
                            "${item.locName ?? ''} (${item.locCode ?? ''})",
                        selectedItem: controller.selectedLocation.value,
                        isLoading: controller.isLoadingAllLocations.value,
                        compareFn: (item, selectedItem) =>
                            item.locCode == selectedItem.locCode,
                      ),
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("CD NO"),
                    CustomTextField(
                      controller: controller.cdNoController,
                      hintText: "Enter CD Number",
                    ),
                    const SizedBox(height: 15),
  
                    Obx(
                      () => Visibility(
                        visible: !controller.isLocalLocation.value,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Co-loader"),
                            Obx(() => CustomSearchDropdown<String>(
                              items: controller.coLoaders,
                              hintText: "Select Co-loader",
                              isLoading: controller.isLoadingCoLoaders.value,
                              selectedItem: controller.selectedCoLoader.value,
                              onSelected: (val) =>
                                  controller.selectedCoLoader.value = val,
                            )),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
  
                    _buildLabel("Vendor Type"),
                    Obx(() => CustomSearchDropdown<String>(
                      items: controller.vendorTypes,
                      hintText: "Select Vendor Type",
                      selectedItem: controller.selectedVendorType.value,
                      onSelected: controller.onVendorTypeChanged,
                    )),
                    const SizedBox(height: 15),
  
                    _buildLabel("Vehicle No"),
                    Obx(
                      () => controller.isOwnVehicle.value
                          ? CustomSearchDropdown<String>(
                              items: controller.vehicles,
                              hintText: "Select Vehicle No",
                              selectedItem: controller.vehicleNo.value,
                              isLoading: controller.isLoadingVehicles.value,
                              onSelected: (val) =>
                                  controller.onVehicleNoChanged(val),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  hintText: "Enter Vehicle No (e.g. GJ21AC4641)",
                                  onChanged: (val) =>
                                      controller.onVehicleNoChanged(val),
                                ),
                                if (!controller.isVehicleNoValid.value)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 5.0, left: 8.0),
                                    child: Text(
                                      "Invalid Indian Vehicle Format",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                              ],
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
                            CustomSearchDropdown<String>(
                              items: controller.tripSheets,
                              hintText: "Select Trip Sheet",
                              selectedItem: controller.tripSheet.value,
                              isLoading: controller.isLoadingTripSheets.value,
                              onSelected: (val) =>
                                  controller.tripSheet.value = val,
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
  
                    _buildLabel("Cnote No"),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: controller.cnoteController,
                            hintText: "Enter Cnote No",
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Obx(() => controller.isValidatingCnote.value
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                onPressed: controller.addCnote,
                                icon: const Icon(Icons.add_circle,
                                    color: AppColors.primaryBlue, size: 35),
                              )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => Column(
                        children: controller.selectedCnotes.isEmpty
                            ? [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "No Cnotes added yet",
                                      style: TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ),
                                )
                              ]
                            : controller.selectedCnotes.map((cnote) {
                                int index = controller.selectedCnotes.indexOf(cnote);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey.shade100),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.receipt_long,
                                            color: AppColors.primaryBlue, size: 20),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          cnote,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => controller.removeCnote(index),
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() => CustomButton(
                    text: "SUBMIT",
                    onPressed: controller.submit,
                    isLoading: controller.isSubmitting.value,
                  )),
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

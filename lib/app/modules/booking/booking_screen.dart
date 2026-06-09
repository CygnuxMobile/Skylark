import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import 'package:skylark/app/core/widgets/custom_search_dropdown.dart';
import 'package:skylark/app/data/models/customer_model.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'package:skylark/app/data/models/pincode_model.dart';
import 'booking_controller.dart';

class BookingScreen extends GetView<BookingController> {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Booking Screen',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Cnote NO'),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: controller.cnoteController,
                        focusNode: controller.cnoteFocus,
                        hintText: 'Enter Cnote Number',
                        isLoading: controller.isValidatingCnote.value,
                        prefixIcon: const Icon(Icons.numbers_rounded, color: AppColors.primaryBlue, size: 20),
                        suffixIcon: controller.cnoteController.text.length >= 4
                            ? Icon(
                                controller.isCnoteValid.value ? Icons.check_circle : Icons.error,
                                color: controller.isCnoteValid.value ? Colors.green : Colors.red,
                                size: 20,
                              )
                            : null,
                      ),
                      if (controller.cnoteValidationMessage.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            controller.cnoteValidationMessage.value,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: controller.isCnoteValid.value ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Eway Bill'),
                Obx(
                  () => CustomTextField(
                    controller: controller.ewayBillController,
                    focusNode: controller.ewayBillFocus,
                    hintText: 'Enter Eway Bill Number',
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    prefixIcon: controller.isLoadingEwayBill.value
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : const Icon(Icons.receipt_long_rounded, color: AppColors.primaryBlue, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Customer Name'),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomSearchDropdown<CustomerModel>(
                        items: controller.customers,
                        focusNode: controller.customerFocus,
                        hintText: 'Select Customer',
                        title: 'Select Customer',
                        onRefresh: () => controller.fetchCustomers(),
                        isLoading: controller.isLoadingCustomers.value,
                        selectedItem: controller.selectedCustomer.value,
                        itemAsString: (customer) => "${customer.custCode ?? ''} - ${customer.custName ?? ''}",
                        compareFn: (item, selectedItem) => item.custCode == selectedItem.custCode && item.custName == selectedItem.custName,
                        validator: (value) => value == null || value.isEmpty ? 'Customer is required' : null,
                        onSelected: (value) {
                          if (value != null) {
                            controller.selectedCustomer.value = value;
                          }
                        },
                      ),
                      if (controller.customerErrorMessage.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Text(controller.customerErrorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Transport Mode'),
                Obx(
                  () => CustomSearchDropdown<Map<String, dynamic>>(
                    items: controller.transportModes,
                    hintText: 'Select Transport Mode',
                    isLoading: controller.isLoadingTransportModes.value,
                    selectedItem: controller.selectedTransportMode.value,
                    itemAsString: (item) => item['codeDesc']?.toString() ?? '',
                    compareFn: (item, selectedItem) => item['codeId'] == selectedItem['codeId'],
                    validator: (value) => value == null || value.isEmpty ? 'Transport Mode is required' : null,
                    onSelected: (value) {
                      controller.selectedTransportMode.value = value;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Origin Pin'),
                          Obx(
                            () => CustomSearchDropdown<PincodeModel>(
                              items: controller.locations,
                              focusNode: controller.originFocus,
                              hintText: 'Origin',
                              isLoading: controller.isLoadingLocations.value,
                              isSearching: controller.isLoadingLocations,
                              selectedItem: controller.selectedOrigin.value,
                              itemAsString: (item) => item.pincode ?? '',
                              onSearch: (val) => controller.fetchPincodes(val),
                              onTap: () => controller.locations.clear(),
                              compareFn: (item, selectedItem) => item.pincode == selectedItem.pincode,
                              validator: (value) => value == null || value.isEmpty ? 'Origin required' : null,
                              onSelected: (value) => controller.onOriginSelected(value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Dest Pin'),
                          Obx(
                            () => CustomSearchDropdown<PincodeModel>(
                              items: controller.locations,
                              focusNode: controller.destFocus,
                              hintText: 'Destination',
                              isLoading: controller.isLoadingLocations.value,
                              isSearching: controller.isLoadingLocations,
                              selectedItem: controller.selectedDest.value,
                              itemAsString: (item) => item.pincode ?? '',
                              onSearch: (val) => controller.fetchPincodes(val),
                              onTap: () => controller.locations.clear(),
                              compareFn: (item, selectedItem) => item.pincode == selectedItem.pincode,
                              validator: (value) => value == null || value.isEmpty ? 'Dest required' : null,
                              onSelected: (value) => controller.onDestSelected(value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Consignor'),
                CustomTextField(
                  controller: controller.consignorController,
                  hintText: 'Consignor Name',
                  enabled: false,
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue, size: 20),
                  validator: (value) => value == null || value.isEmpty ? 'Consignor is required' : null,
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Consignee'),
                Obx(
                  () => CustomSearchDropdown<CustomerModel>(
                    items: controller.consignees,
                    focusNode: controller.consigneeFocus,
                    hintText: 'Select Consignee',
                    title: 'Select Consignee',
                    onRefresh: () => controller.fetchConsigneesByPincode(controller.selectedDest.value?.pincode ?? ''),
                    isLoading: controller.isLoadingConsignees.value,
                    selectedItem: controller.selectedConsignee.value,
                    itemAsString: (item) => "${item.custCode ?? ''} - ${item.custName ?? ''}",
                    compareFn: (item, selectedItem) => item.custCode == selectedItem.custCode,
                    validator: (value) => value == null || value.isEmpty ? 'Consignee required' : null,
                    onSelected: (value) {
                      controller.selectedConsignee.value = value;
                      if (value != null) {
                        controller.consigneeController.text = value.custName ?? '';
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('PKGS'),
                          Obx(
                            () => CustomTextField(
                              controller: controller.pkgsController,
                              focusNode: controller.pkgsFocus,
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              readOnly: controller.isFieldsReadOnly.value,
                              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Actual Weight'),
                          Obx(
                            () => CustomTextField(
                              controller: controller.aWeightController,
                              focusNode: controller.aWeightFocus,
                              hintText: '0.00',
                              readOnly: controller.isFieldsReadOnly.value,
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Invoice Value'),
                Obx(
                  () => CustomTextField(
                    controller: controller.invValueController,
                    focusNode: controller.invValueFocus,
                    hintText: 'Enter INV Value',
                    keyboardType: TextInputType.number,
                    readOnly: controller.isFieldsReadOnly.value,
                    prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.primaryBlue, size: 20),
                    validator: (value) => value == null || value.isEmpty ? 'Value is required' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Invoice Number'),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: controller.invNoController,
                        focusNode: controller.invNoFocus,
                        hintText: 'Enter INV No',
                        readOnly: controller.isFieldsReadOnly.value,
                        prefixIcon: controller.isLoadingFreight.value
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : const Icon(Icons.description_outlined, color: AppColors.primaryBlue, size: 20),
                        validator: (value) => value == null || value.isEmpty ? 'INV No is required' : null,
                      ),
                      if (controller.freightErrorMessage.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Text(
                            controller.freightErrorMessage.value,
                            style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => controller.toggleDimensions(),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(controller.showDimensions.value ? Icons.remove_circle_outline : Icons.add_circle_outline, color: AppColors.primaryBlue, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                controller.showDimensions.value ? 'HIDE DIMENSIONS' : 'ADD DIMENSIONS',
                                style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (controller.showDimensions.value) ...[const SizedBox(height: 16), _buildDimensionSection()],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Obx(() => CustomButton(text: 'SUBMIT BOOKING', isLoading: controller.isLoadingBooking.value, onPressed: () => controller.submitBooking())),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkBlue, letterSpacing: 0.3),
      ),
    );
  }

  Widget _buildDimensionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Dimensions (L x B x H)'),
        Row(
          children: [
            _buildSmallDimField('L', controller.lengthController),
            const SizedBox(width: 12),
            _buildSmallDimField('B', controller.breadthController),
            const SizedBox(width: 12),
            _buildSmallDimField('H', controller.heightController),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallDimField(String label, TextEditingController textController) {
    return Expanded(
      child: CustomTextField(controller: textController, hintText: label, keyboardType: TextInputType.number),
    );
  }
}

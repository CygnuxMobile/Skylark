import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import 'package:skylark/app/core/widgets/custom_search_dropdown.dart';
import 'package:skylark/app/data/models/customer_model.dart';
import 'package:skylark/app/data/models/location_model.dart';
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Booking Screen',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Cnote NO'),
              CustomTextField(
                controller: controller.cnoteController,
                hintText: 'Enter Cnote Number',
                prefixIcon: const Icon(
                  Icons.numbers_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Cnote number is required'
                    : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Eway Bill'),
              Obx(
                () => CustomTextField(
                  controller: controller.ewayBillController,
                  hintText: 'Enter Eway Bill Number',
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  prefixIcon: controller.isLoadingEwayBill.value
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Eway bill is required';
                    if (value.length != 12)
                      return 'Eway bill must be 12 digits';
                    return null;
                  },
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
                      hintText: 'Select Customer',
                      isLoading: controller.isLoadingCustomers.value,
                      selectedItem: controller.selectedCustomer.value,
                      itemAsString: (customer) =>
                          "${customer.custCode ?? ''} - ${customer.custName ?? ''}",
                      compareFn: (item, selectedItem) =>
                          item.custCode == selectedItem.custCode &&
                          item.custName == selectedItem.custName,
                      onSelected: (value) {
                        if (value != null) {
                          controller.selectedCustomer.value = value;
                        }
                      },
                    ),
                    if (controller.customerErrorMessage.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          controller.customerErrorMessage.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
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
                          () => CustomSearchDropdown<LocationModel>(
                            items: controller.locations,
                            hintText: 'Origin',
                            isLoading: controller.isLoadingLocations.value,
                            selectedItem: controller.selectedOrigin.value,
                            itemAsString: (item) =>
                                "${item.locCode ?? ''} - ${item.locName ?? ''}",
                            compareFn: (item, selectedItem) =>
                                item.locCode == selectedItem.locCode,
                            onSelected: (value) {
                              controller.selectedOrigin.value = value;
                              if (value != null) {
                                controller.originPinController.text = value.locCode ?? '';
                              }
                            },
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
                          () => CustomSearchDropdown<LocationModel>(
                            items: controller.locations,
                            hintText: 'Destination',
                            isLoading: controller.isLoadingLocations.value,
                            selectedItem: controller.selectedDest.value,
                            itemAsString: (item) =>
                                "${item.locCode ?? ''} - ${item.locName ?? ''}",
                            compareFn: (item, selectedItem) =>
                                item.locCode == selectedItem.locCode,
                            onSelected: (value) {
                              controller.selectedDest.value = value;
                              if (value != null) {
                                controller.destPinController.text = value.locCode ?? '';
                              }
                            },
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
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Consignor is required'
                    : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Consignee'),
              Obx(
                () => CustomSearchDropdown<CustomerModel>(
                  items: controller.consignees,
                  hintText: 'Select Consignee',
                  isLoading: controller.isLoadingConsignees.value,
                  selectedItem: controller.selectedConsignee.value,
                  itemAsString: (item) =>
                      "${item.custCode ?? ''} - ${item.custName ?? ''}",
                  compareFn: (item, selectedItem) =>
                      item.custCode == selectedItem.custCode,
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
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            readOnly: controller.isFieldsReadOnly.value,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
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
                            hintText: '0.00',
                            readOnly: controller.isFieldsReadOnly.value,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Invoice Number'),
              Obx(
                () => CustomTextField(
                  controller: controller.invNoController,
                  hintText: 'Enter INV No',
                  readOnly: controller.isFieldsReadOnly.value,
                  prefixIcon: const Icon(
                    Icons.description_outlined,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'INV No is required'
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Invoice Value'),
              Obx(
                () => CustomTextField(
                  controller: controller.invValueController,
                  hintText: 'Enter INV Value',
                  keyboardType: TextInputType.number,
                  readOnly: controller.isFieldsReadOnly.value,
                  prefixIcon: const Icon(
                    Icons.currency_rupee_rounded,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Value is required'
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              Obx(() => Column(
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
                          Icon(
                            controller.showDimensions.value 
                                ? Icons.remove_circle_outline 
                                : Icons.add_circle_outline,
                            color: AppColors.primaryBlue,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.showDimensions.value 
                                ? 'HIDE DIMENSIONS' 
                                : 'ADD DIMENSIONS',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (controller.showDimensions.value) ...[
                    const SizedBox(height: 16),
                    _buildDimensionSection(),
                  ],
                ],
              )),

              const SizedBox(height: 32),

              CustomButton(
                text: 'SUBMIT BOOKING',
                onPressed: () => controller.submitBooking(),
              ),
              const SizedBox(height: 40),
            ],
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
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBlue,
          letterSpacing: 0.3,
        ),
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

  Widget _buildSmallDimField(
    String label,
    TextEditingController textController,
  ) {
    return Expanded(
      child: CustomTextField(
        controller: textController,
        hintText: label,
        keyboardType: TextInputType.number,
      ),
    );
  }
}

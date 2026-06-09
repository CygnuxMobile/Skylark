import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_search_dropdown.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'expense_controller.dart';

class ExpenseScreen extends GetView<ExpenseController> {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Branch Daily Expense Entry', 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBranchDropdown(),
              const SizedBox(height: 20),
              _buildDatePicker(context),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildTextField("Total KM", controller.totalKmController, keyboardType: TextInputType.number)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildFloorField()),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField("Paid To *", controller.paidToController),
              const SizedBox(height: 20),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildDocTypeDropdown()),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Against No. *",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue)),
                        const SizedBox(height: 8),
                        Obx(() => CustomTextField(
                              controller: controller.againstController,
                              hintText: "Enter No.",
                              isLoading: controller.isValidatingDoc.value,
                              suffixIcon: controller.againstController.text.isNotEmpty
                                  ? Icon(
                                      controller.isDocValid.value
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: controller.isDocValid.value
                                          ? Colors.green
                                          : Colors.red,
                                      size: 20,
                                    )
                                  : null,
                              onChanged: (val) {
                                if (val.length >= 3) {
                                  controller.validateDocument(val);
                                } else {
                                  controller.isDocValid.value = false;
                                  controller.docValidationMessage.value = "";
                                }
                              },
                            )),
                        Obx(() => controller.docValidationMessage.value.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4, left: 4),
                                child: Text(
                                  controller.docValidationMessage.value,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: controller.isDocValid.value
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField("Description *", controller.descriptionController),
              const SizedBox(height: 20),
              _buildTextField("Amount (₹) *", controller.amountController, keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              _buildPaymentModeField(),
              const SizedBox(height: 20),
              _buildTextField("Remarks (Optional)", controller.remarksController, maxLines: 2),
              const SizedBox(height: 25),
              _buildUploadReceipt(),
              const SizedBox(height: 35),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : () => controller.saveExpense(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Save Expense",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Branch", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        Obx(() => CustomSearchDropdown<LocationModel>(
          items: controller.locations,
          hintText: "Select Branch",
          isLoading: controller.isLoadingLocations.value,
          selectedItem: controller.selectedBranch.value,
          itemAsString: (loc) => "${loc.locName} (${loc.locCode})",
          onSelected: (val) {
            if (val != null) {
              controller.selectedBranch.value = val;
            }
          },
          compareFn: (i, s) => i.locCode == s.locCode,
        )),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Date", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        Obx(() => InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: controller.selectedDate.value,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null) controller.selectedDate.value = date;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryBlue),
                const SizedBox(width: 10),
                Text(DateFormat('dd MMM yyyy').format(controller.selectedDate.value)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildFloorField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Floor", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.floorController,
          hintText: "Enter Floor",
        ),
      ],
    );
  }

  Widget _buildDocTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("DocType", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        Obx(() {
          String? selectedKey;
          try {
            selectedKey = controller.docTypes.entries
                .firstWhere((entry) => entry.value == controller.selectedDocType.value)
                .key;
          } catch (_) {
            selectedKey = null;
          }
              
          return CustomSearchDropdown<String>(
            items: controller.docTypes.keys.toList(),
            hintText: "Select DocType",
            selectedItem: selectedKey,
            onSelected: (val) {
              if (val != null) {
                controller.selectedDocType.value = controller.docTypes[val]!;
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController textController, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Category *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        Obx(() => CustomSearchDropdown<Map<String, dynamic>>(
          items: controller.accounts,
          hintText: "Search Category (e.g. Fuel, Rent)",
          selectedItem: controller.selectedAccount.value,
          isSearching: controller.isLoadingAccounts,
          itemAsString: (item) => "${item['accdesc']} (${item['acccode']})",
          onSearch: (val) => controller.searchAccounts(val),
          onSelected: (val) {
            controller.selectedAccount.value = val;
          },
          compareFn: (i1, i2) => i1['acccode'] == i2['acccode'],
        )),
      ],
    );
  }

  Widget _buildPaymentModeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Payment Mode", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Text(
            "Cash",
            style: TextStyle(
              fontSize: 15, 
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadReceipt() {
    return Column(
      children: [
        InkWell(
          onTap: () => _showPickerOptions(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_file, color: AppColors.primaryBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Upload Receipt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkBlue)),
                      Text("JPG or PNG (Max 5 MB)", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: 20),
              ],
            ),
          ),
        ),
        Obx(() {
          if (controller.frontDocument.value.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              const SizedBox(height: 10),
              _buildFileTile("Receipt: ${controller.frontFileName.value}", () => controller.removeDocument(true)),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildFileTile(String name, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.image_outlined, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name, 
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showPickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text("Upload Receipt", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      controller.pickDocument(true, ImageSource.camera);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryBlue, size: 30),
                        ),
                        const SizedBox(height: 10),
                        const Text("Camera", style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      controller.pickDocument(true, ImageSource.gallery);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.image_outlined, color: AppColors.primaryBlue, size: 30),
                        ),
                        const SizedBox(height: 10),
                        const Text("Gallery", style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

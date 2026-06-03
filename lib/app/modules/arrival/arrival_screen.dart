import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'arrival_controller.dart';

class ArrivalScreen extends GetView<ArrivalController> {
  const ArrivalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Arrival', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.arrivalList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  "No arrivals found",
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.fetchArrivalList(),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text(
                    "Retry",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchArrivalList(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.arrivalList.length,
            itemBuilder: (context, index) {
              final arrival = controller.arrivalList[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  title: Text(
                    "${arrival['thcno'] ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Date: ${arrival['thcDate'] ?? ''}"),
                      Text("Vehicle: ${arrival['vehicle'] ?? ''}"),
                      Text("From: ${arrival['previousBranch'] ?? ''} -> To: ${arrival['nextLocation'] ?? ''}"),
                    ],
                  ),
                  trailing: (arrival['ata'] == null || arrival['ata'] == "")
                      ? ElevatedButton(
                          onPressed: () => _showArrivalSubmitBottomSheet(context, arrival),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Submit"),
                        )
                      : const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showArrivalSubmitBottomSheet(BuildContext context, Map<String, dynamic> arrival) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              "THC: ${arrival['thcno'] ?? ''}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
            ),
            const SizedBox(height: 20),
            const Text(
              "Arrival Status",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue),
            ),
            const SizedBox(height: 10),
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.selectedStatus.value,
                  items: controller.statusItems.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) controller.selectedStatus.value = newValue;
                  },
                ),
              ),
            )),
            const SizedBox(height: 20),
            const Text(
              "Close KM",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.closeKmController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Close KM",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : () => controller.submitTHCArrival(arrival),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: controller.isSubmitting.value
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      "SUBMIT ARRIVAL",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
              )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              "Filter Options",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "From Date",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue),
                      ),
                      const SizedBox(height: 10),
                      Obx(() => InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: controller.fromDate.value ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) controller.fromDate.value = date;
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            controller.fromDate.value != null
                              ? DateFormat('dd MMM yyyy').format(controller.fromDate.value!)
                              : "Select Date",
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "To Date",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue),
                      ),
                      const SizedBox(height: 10),
                      Obx(() => InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: controller.toDate.value ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) controller.toDate.value = date;
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            controller.toDate.value != null
                              ? DateFormat('dd MMM yyyy').format(controller.toDate.value!)
                              : "Select Date",
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final now = DateTime.now();
                      controller.toDate.value = now;
                      controller.fromDate.value = now.subtract(const Duration(days: 7));
                      Get.back();
                      controller.fetchArrivalList();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      "RESET",
                      style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.fetchArrivalList();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "APPLY",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

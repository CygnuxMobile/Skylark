import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import 'manifest_controller.dart';
import 'sub_screen/manifest_arrival_detail_screen.dart';

class ManifestScreen extends GetView<ManifestController> {
  const ManifestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Manifest Arrival List',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterSection(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.manifestList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredManifestList.isEmpty) {
                return const Center(child: Text("No Data Found", style: TextStyle(color: Colors.grey)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: controller.filteredManifestList.length,
                itemBuilder: (context, index) {
                  return _buildManifestCard(controller.filteredManifestList[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDatePicker(context, "From Date", controller.fromDate, controller.updateFromDate)),
              const SizedBox(width: 15),
              Expanded(child: _buildDatePicker(context, "To Date", controller.toDate, controller.updateToDate)),
            ],
          ),
          const SizedBox(height: 15),
          Obx(() => CustomTextField(
            controller: controller.thcSearchController,
            hintText: "Search MF No. (Real-time)",
            prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
            suffixIcon: controller.searchText.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                    onPressed: () => controller.clearSearch(),
                  )
                : null,
          )),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, Rx<DateTime> dateObs, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 5),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: dateObs.value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) onDateSelected(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Obx(() => Text(
                  DateFormat('dd MMM yy').format(dateObs.value),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManifestCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderInfo("MF NO", data['mf'] ?? "N/A", color: AppColors.primaryBlue),
                    _buildHeaderInfo("MF Date", data['mF_Date'] ?? "N/A", alignRight: true),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildInfoRow(Icons.route_outlined, "Route", data['route'] ?? "N/A"),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.confirmation_number_outlined, "CD NO", data['cdno'] ?? "N/A"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildInfoRow(Icons.business_center_outlined, "Vendor", data['vendorname'] ?? "N/A")),
                    Container(height: 25, width: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 10)),
                    Expanded(child: _buildInfoRow(Icons.inventory_2_outlined, "Dockets", (data['docketKount'] ?? 0).toString())),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Get.to(() => ManifestArrivalDetailScreen(manifestData: data)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: const Text(
                "View Details",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(String label, String value, {bool alignRight = false, Color? color}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color ?? AppColors.darkBlue)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ],
    );
  }
}

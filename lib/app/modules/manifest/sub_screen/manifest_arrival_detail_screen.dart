import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import '../manifest_controller.dart';

class ManifestArrivalDetailScreen extends StatefulWidget {
  final Map<String, dynamic> manifestData;
  const ManifestArrivalDetailScreen({super.key, required this.manifestData});

  @override
  State<ManifestArrivalDetailScreen> createState() => _ManifestArrivalDetailScreenState();
}

class _ManifestArrivalDetailScreenState extends State<ManifestArrivalDetailScreen> {
  final ManifestController controller = Get.find<ManifestController>();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final remarkController = TextEditingController();
  final destinationKmController = TextEditingController();
  final coLoaderController = TextEditingController();
  
  String selectedStatus = 'Ok';
  final List<String> statusOptions = ['Ok', 'Broken', 'Unsealed'];

  @override
  void initState() {
    super.initState();
    String vendor = widget.manifestData['vendorname'] ?? "";
    if (vendor.isNotEmpty && vendor != "N/A") {
      coLoaderController.text = vendor;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchManifestDetails(widget.manifestData['mf'] ?? "");
    });
  }

  @override
  void dispose() {
    remarkController.dispose();
    destinationKmController.dispose();
    coLoaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Manifest Submit',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildManifestSummary(),
                  const SizedBox(height: 20),
                  _buildDocketListSection(),
                  const SizedBox(height: 25),
                  
                  _buildLabel("Destination KM"),
                  CustomTextField(
                    controller: destinationKmController,
                    hintText: "Enter Destination KM",
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.speed, color: AppColors.primaryBlue),
                    validator: (value) => value == null || value.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Status"),
                  _buildStatusDropdown(),
                  const SizedBox(height: 20),
  
                  _buildLabel("Co-loader Name"),
                  CustomTextField(
                    controller: coLoaderController,
                    hintText: "Enter Co-loader Name",
                    enabled: widget.manifestData['vendorname'] == null || 
                             widget.manifestData['vendorname'] == "" || 
                             widget.manifestData['vendorname'] == "N/A",
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryBlue),
                    validator: (value) => value == null || value.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 20),
  
                  _buildLabel("Remark"),
                  CustomTextField(
                    controller: remarkController,
                    hintText: "Enter Remarks",
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 40),
  
                  Obx(() => CustomButton(
                    text: "SUBMIT MANIFEST",
                    isLoading: controller.isSubmitting.value,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        controller.submitManifest(
                          status: selectedStatus,
                          remark: remarkController.text,
                          destinationKm: destinationKmController.text,
                        );
                      }
                    },
                  )),
                ],
              ),
            ),
          ),
          Obx(() => controller.isLoadingDetails.value
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildManifestSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildSummaryRow("MF No", widget.manifestData['mf'] ?? "N/A", isBold: true),
          const Divider(height: 30),
          _buildSummaryRow("CD NO", widget.manifestData['cdno'] ?? "N/A"),
          const SizedBox(height: 12),
          _buildSummaryRow("MF Date", widget.manifestData['mF_Date'] ?? "N/A"),
          const SizedBox(height: 12),
          _buildSummaryRow("Route", widget.manifestData['route'] ?? "N/A"),
          const SizedBox(height: 12),
          Obx(() => _buildSummaryRow("Total Count", controller.detailData.length.toString(), isBold: true)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: AppColors.darkBlue,
          fontSize: 14,
        )),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedStatus,
          items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (val) => setState(() => selectedStatus = val!),
        ),
      ),
    );
  }

  Widget _buildDocketListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Docket Details"),
        Obx(() {
          if (controller.detailData.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(child: Text("No dockets found", style: TextStyle(color: Colors.grey))),
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(AppColors.primaryBlue.withOpacity(0.1)),
                  dataRowMaxHeight: 60,
                  horizontalMargin: 15,
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('LR', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue))),
                    DataColumn(label: Text('Pc', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue))),
                    DataColumn(label: Text('Wt', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue))),
                    DataColumn(label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue))),
                    DataColumn(label: Text('From', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue))),
                    DataColumn(label: Text('To', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue))),
                  ],
                  rows: controller.detailData.map((e) {
                    return DataRow(cells: [
                      DataCell(Text(e['dockNo']?.toString() ?? e['dockno']?.toString() ?? "N/A")),
                      DataCell(Text(e['pkgsno']?.toString() ?? "0")),
                      DataCell(Text(e['actuwt']?.toString() ?? "0.0")),
                      DataCell(SizedBox(
                        width: 150,
                        child: Text(
                          e['party_name']?.toString() ?? e['consignee']?.toString() ?? e['party']?.toString() ?? "N/A",
                          style: const TextStyle(fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(Text(e['orgncd']?.toString() ?? "N/A")),
                      DataCell(Text(e['desT_CD']?.toString() ?? "N/A")),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

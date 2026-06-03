import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import '../stock_update_controller.dart';

class StockUpdateDetailScreen extends GetView<StockUpdateController> {
  const StockUpdateDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text('Stock Update Details'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // FIXED HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHeaderRow('Manifest No', controller.selectedManifest.value ?? '-', Icons.assignment_outlined),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeaderRow('Total Cnote', controller.totalCnoteController.text, Icons.inventory_2_outlined),
                      ),
                      Container(width: 1, height: 30, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 10)),
                      Expanded(
                        child: _buildHeaderRow('Co-Loader', controller.coLoaderNameController.text, Icons.local_shipping_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // SCROLLABLE DOCKET LIST
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.dockets.length + 1, // +1 for the label row
              itemBuilder: (context, index) {
                if (index == 0) {
                  // This is the "DOCKET LIST" label at the top of the scrollable area
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 12, left: 4),
                    child: Row(
                      children: [
                        Icon(Icons.list_alt, color: AppColors.primaryBlue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'DOCKET LIST',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docket = controller.dockets[index - 1];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "LR No: ${docket['lr']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          docket['client'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${docket['from']} to ${docket['to']}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomButton(
          text: 'SUBMIT STOCK UPDATE',
          onPressed: () => controller.submitStockUpdate(),
          width: double.infinity,
          color: AppColors.primaryBlue,
          textColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeaderRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: const TextStyle(color: AppColors.darkBlue, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

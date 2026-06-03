import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'pod_upload_controller.dart';

class PODUploadScreen extends GetView<PODUploadController> {
  const PODUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('POD Upload', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.podList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  "No POD records found",
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.fetchPODList(),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text(
                    "Retry",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                  ),
                )
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchPODList(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.podList.length,
            itemBuilder: (context, index) {
              final pod = controller.podList[index];
              
              String displayDate = pod['dockdt'] ?? 'N/A';
              try {
                if (pod['dockdt'] != null) {
                  DateTime dt = DateTime.parse(pod['dockdt']);
                  displayDate = DateFormat('dd-MM-yyyy').format(dt);
                }
              } catch (e) {}

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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(
                    "Dock No: ${pod['dockno'] ?? 'N/A'}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Date: $displayDate"),
                    ],
                  ),
                  trailing: InkWell(
                    onTap: () => _showImagePickerSheet(pod['dockno'] ?? 'N/A'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryBlue),
                    ),
                  ),
                  onTap: () => _showImagePickerSheet(pod['dockno'] ?? 'N/A'),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showImagePickerSheet(String gcNo) {
    controller.clearImages();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
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
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Upload POD - $gcNo",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(child: _buildImageSelector("Front Side", true, gcNo)),
                const SizedBox(width: 20),
                Expanded(child: _buildImageSelector("Back Side", false, gcNo)),
              ],
            ),
            const SizedBox(height: 35),
            Obx(() => CustomButton(
              text: "SUBMIT POD",
              isLoading: controller.isUploading.value,
              onPressed: () => controller.submitPOD(gcNo),
            )),
            const SizedBox(height: 10),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildImageSelector(String label, bool isFront, String gcNo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Obx(() {
          final image = isFront ? controller.frontImage.value : controller.backImage.value;
          return GestureDetector(
            onTap: () => _showSourceSelection(isFront, gcNo),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(image, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, color: AppColors.primaryBlue.withOpacity(0.5), size: 30),
                        const SizedBox(height: 8),
                        const Text("Tap to Capture", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
            ),
          );
        }),
      ],
    );
  }

  void _showSourceSelection(bool isFront, String gcNo) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Image Source",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: _sourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: "Camera",
                    onTap: () {
                      Get.back();
                      controller.pickImage(isFront, ImageSource.camera, gcNo);
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _sourceButton(
                    icon: Icons.photo_library_rounded,
                    label: "Gallery",
                    onTap: () {
                      Get.back();
                      controller.pickImage(isFront, ImageSource.gallery, gcNo);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _sourceButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_search_dropdown.dart';
import 'package:skylark/app/core/widgets/custom_snackbar.dart';
import 'package:skylark/app/routes/app_routes.dart';
import 'dashboard_controller.dart';
import 'widgets/dashboard_drawer.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      drawer: const DashboardDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Location",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final locationList = controller.locations
                      .map((loc) => "${loc.locName ?? ''} (${loc.locCode ?? ''})")
                      .toList();

                  return CustomSearchDropdown(
                    isLoading: controller.isLoadingLocations.value,
                    items: locationList,
                    hintText: "Search & Select Location",
                    selectedItem: controller.selectedLocation.value != null 
                        ? "${controller.selectedLocation.value!.locName} (${controller.selectedLocation.value!.locCode})"
                        : null,
                    onSelected: (String? value) {
                      if (value != null) {
                        final selected = controller.locations.firstWhereOrNull(
                          (loc) => "${loc.locName} (${loc.locCode})" == value,
                        );
                        if (selected != null) {
                          controller.onLocationChanged(selected);
                        }
                      }
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _menuTile(
                  icon: Icons.edit_document,
                  title: 'Booking Screen',
                  subtitle: 'Manage and create new bookings',
                  color: AppColors.primaryBlue,
                  onTap: () {
                    if (controller.selectedLocation.value == null) {
                      CustomSnackbar.show(
                        title: 'Location Required',
                        message: 'Please select a location first',
                        backgroundColor: Colors.orange,
                      );
                    } else {
                      Get.toNamed(AppRoutes.booking);
                    }
                  },
                ),
                _menuTile(
                  icon: Icons.local_shipping_rounded,
                  title: 'Arrival',
                  subtitle: 'Manage shipment arrivals',
                  color: AppColors.secondaryGreen,
                  onTap: () => Get.toNamed(AppRoutes.arrival),
                ),
                _menuTile(
                  icon: Icons.assignment_rounded,
                  title: 'PRS',
                  subtitle: 'Pickup Request System',
                  color: AppColors.primaryBlue,
                  onTap: () => Get.toNamed(AppRoutes.prs),
                ),
                _menuTile(
                  icon: Icons.assignment_turned_in_rounded,
                  title: 'PRS Closure',
                  subtitle: 'Complete pending pickup requests',
                  color: AppColors.secondaryGreen,
                  onTap: () => Get.toNamed(AppRoutes.prsClosure),
                ),
                _menuTile(
                  icon: Icons.local_shipping_rounded,
                  title: 'DRS Generation',
                  subtitle: 'Generate Delivery Run Sheets',
                  color: AppColors.primaryBlue,
                  onTap: () => Get.toNamed(AppRoutes.drsGeneration),
                ),
                _menuTile(
                  icon: Icons.done_all_rounded,
                  title: 'DRS Closure',
                  subtitle: 'Complete and close delivery run sheets',
                  color: AppColors.secondaryGreen,
                  onTap: () => Get.toNamed(AppRoutes.drsClosure),
                ),
                _menuTile(
                  icon: Icons.cloud_upload_rounded,
                  title: 'POD Upload',
                  subtitle: 'Search and upload proof of delivery',
                  color: AppColors.darkBlue,
                  onTap: () => Get.toNamed(AppRoutes.podUpload),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned(
                  right: -15,
                  top: -15,
                  child: Icon(
                    icon,
                    size: 100,
                    color: color.withValues(alpha: 0.03),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBlue,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow button
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: color.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

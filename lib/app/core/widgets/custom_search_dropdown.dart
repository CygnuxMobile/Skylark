import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';

class CustomSearchDropdown<T> extends StatelessWidget {
  final List<T> items;
  final String hintText;
  final Function(T?) onSelected;
  final T? selectedItem;
  final bool isLoading;
  final String Function(T)? itemAsString;
  final bool Function(T, String)? filterFn;
  final bool Function(T, T)? compareFn;

  const CustomSearchDropdown({
    super.key,
    required this.items,
    required this.hintText,
    required this.onSelected,
    this.selectedItem,
    this.isLoading = false,
    this.itemAsString,
    this.filterFn,
    this.compareFn,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = "";
    if (selectedItem != null) {
      displayText = itemAsString != null ? itemAsString!(selectedItem as T) : selectedItem.toString();
    }

    return GestureDetector(
      onTap: isLoading ? null : () => _showBottomSheet(context),
      child: AbsorbPointer(
        child: CustomTextField(
          controller: TextEditingController(text: displayText),
          hintText: hintText,
          isLoading: isLoading,
          suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
          enabled: !isLoading,
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    final searchController = TextEditingController();
    final filteredItems = RxList<T>(items);
    final currentSelection = Rxn<T>(selectedItem);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 45,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "Select Option",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: TextField(
                controller: searchController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Search here...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue, size: 24),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  if (val.isEmpty) {
                    filteredItems.assignAll(items);
                  } else {
                    filteredItems.assignAll(items.where((i) {
                      final str = itemAsString != null ? itemAsString!(i) : i.toString();
                      return str.toLowerCase().contains(val.toLowerCase());
                    }).toList());
                  }
                },
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey, height: 1),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final str = itemAsString != null ? itemAsString!(item) : item.toString();
                    
                    bool isSelected = false;
                    if (currentSelection.value != null) {
                      if (compareFn != null) {
                        try {
                          isSelected = compareFn!(item, currentSelection.value as T);
                        } catch (e) {
                          isSelected = false;
                        }
                      } else {
                        isSelected = item == currentSelection.value;
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                      child: ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                        title: Text(
                          str,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.primaryBlue : Colors.black87,
                          ),
                        ),
                        trailing: isSelected 
                          ? const Icon(Icons.check, color: AppColors.primaryBlue, size: 20)
                          : null,
                        onTap: () {
                          currentSelection.value = item;
                          onSelected(item);
                          Future.delayed(const Duration(milliseconds: 200), () => Get.back());
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

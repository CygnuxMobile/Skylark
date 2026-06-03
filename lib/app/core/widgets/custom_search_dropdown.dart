import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';

class CustomSearchDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String hintText;
  final Function(T?) onSelected;
  final T? selectedItem;
  final bool isLoading;
  final RxBool? isSearching;
  final String Function(T)? itemAsString;
  final bool Function(T, String)? filterFn;
  final bool Function(T, T)? compareFn;
  final Function(String)? onSearch;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const CustomSearchDropdown({
    super.key,
    required this.items,
    required this.hintText,
    required this.onSelected,
    this.selectedItem,
    this.isLoading = false,
    this.isSearching,
    this.itemAsString,
    this.filterFn,
    this.compareFn,
    this.onSearch,
    this.onTap,
    this.validator,
    this.focusNode,
  });

  @override
  State<CustomSearchDropdown<T>> createState() => _CustomSearchDropdownState<T>();
}

class _CustomSearchDropdownState<T> extends State<CustomSearchDropdown<T>> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _getDisplayText(widget.selectedItem));
  }

  @override
  void didUpdateWidget(covariant CustomSearchDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      Future.microtask(() {
        if (mounted) {
          _controller.text = _getDisplayText(widget.selectedItem);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getDisplayText(T? item) {
    if (item == null) return "";
    return widget.itemAsString != null ? widget.itemAsString!(item) : item.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : () {
        if (widget.onTap != null) widget.onTap!();
        _showBottomSheet(context);
      },
      child: AbsorbPointer(
        child: CustomTextField(
          controller: _controller,
          focusNode: widget.focusNode,
          hintText: widget.hintText,
          isLoading: widget.isLoading,
          suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
          enabled: !widget.isLoading,
          validator: widget.validator,
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    final searchController = TextEditingController();
    final searchText = "".obs;
    final filteredItems = RxList<T>(widget.items);
    final currentSelection = Rxn<T>(widget.selectedItem);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
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
                  searchText.value = val;
                  if (widget.onSearch != null) {
                    widget.onSearch!(val);
                  } else {
                    if (val.isEmpty) {
                      filteredItems.assignAll(widget.items);
                    } else {
                      filteredItems.assignAll(widget.items.where((i) {
                        final str = widget.itemAsString != null ? widget.itemAsString!(i) : i.toString();
                        return str.toLowerCase().contains(val.toLowerCase());
                      }).toList());
                    }
                  }
                },
              ),
            ),
            widget.isSearching != null 
              ? Obx(() => widget.isSearching!.value 
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                        minHeight: 2,
                      ),
                    ) 
                  : const SizedBox(height: 2))
              : const SizedBox(height: 2),
            const SizedBox(height: 5),
            Expanded(
              child: Obx(() {
                final currentSearchText = searchText.value;
                final searching = widget.isSearching?.value ?? false;
                final displayList = widget.onSearch != null ? widget.items : filteredItems;
                
                if (displayList.isEmpty && !searching) {
                  if (widget.onSearch != null && currentSearchText.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded, size: 50, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          Text(
                            "Search for pincode here",
                            style: TextStyle(color: Colors.grey[500], fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: Text(
                      currentSearchText.isEmpty ? "No data found" : "No results found for '$currentSearchText'",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  );
                }

                return ListView.separated(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemCount: displayList.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.grey, height: 0.5),
                  itemBuilder: (context, index) {
                    final item = displayList[index];
                    final str = widget.itemAsString != null ? widget.itemAsString!(item) : item.toString();
                    
                    bool isSelected = false;
                    if (currentSelection.value != null) {
                      if (widget.compareFn != null) {
                        try {
                          isSelected = widget.compareFn!(item, currentSelection.value as T);
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
                          Get.back(); 
                          widget.onSelected(item);
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

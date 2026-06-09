import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';

class CustomSearchDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String hintText;
  final String? title;
  final Function(T?) onSelected;
  final T? selectedItem;
  final bool isLoading;
  final RxBool? isSearching;
  final String Function(T)? itemAsString;
  final bool Function(T, String)? filterFn;
  final bool Function(T, T)? compareFn;
  final Function(String)? onSearch;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const CustomSearchDropdown({
    super.key,
    required this.items,
    required this.hintText,
    required this.onSelected,
    this.title,
    this.selectedItem,
    this.isLoading = false,
    this.isSearching,
    this.itemAsString,
    this.filterFn,
    this.compareFn,
    this.onSearch,
    this.onRefresh,
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
    FocusScope.of(context).unfocus();
    
    final searchController = TextEditingController();
    final searchText = "".obs;
    final currentSelection = Rxn<T>(widget.selectedItem);
    final isRefreshing = false.obs;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.85),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    widget.title ?? "Select Option",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  if (widget.onRefresh != null)
                    Obx(() => isRefreshing.value 
                      ? const SizedBox(width: 40, height: 40, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                      : IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
                          onPressed: () async {
                            isRefreshing.value = true;
                            await widget.onRefresh!();
                            isRefreshing.value = false;
                          },
                        ))
                  else
                    const SizedBox(width: 40),
                ],
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
                  suffixIcon: Obx(() => searchText.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                          onPressed: () {
                            searchController.clear();
                            searchText.value = "";
                            if (widget.onSearch != null) {
                              widget.onSearch!("");
                            }
                          },
                        )
                      : const SizedBox.shrink()),
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
                final currentSearchText = searchText.value.toLowerCase().trim();
                final searching = widget.isSearching?.value ?? false;

                // Always use the latest list from widget.items
                final List<T> displayList = widget.onSearch != null 
                    ? widget.items 
                    : widget.items.where((item) {
                        if (currentSearchText.isEmpty) return true;
                        final str = widget.itemAsString != null ? widget.itemAsString!(item) : item.toString();
                        return str.toLowerCase().contains(currentSearchText);
                      }).toList();

                if (displayList.isEmpty && !searching) {
                  return SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.onSearch != null && currentSearchText.isEmpty) ...[
                              Icon(Icons.search_rounded, size: 50, color: Colors.grey[300]),
                              const SizedBox(height: 10),
                              Text(
                                "Type to search",
                                style: TextStyle(color: Colors.grey[500], fontSize: 16),
                              ),
                            ] else ...[
                              Icon(Icons.info_outline_rounded, size: 50, color: Colors.grey[300]),
                              const SizedBox(height: 10),
                              Text(
                                currentSearchText.isEmpty ? "No data available" : "No results found for '$currentSearchText'",
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemCount: displayList.length,
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

                    return Column(
                      children: [
                        ListTile(
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
                        if (index < displayList.length - 1)
                          const Divider(color: Colors.grey, height: 1, indent: 15, endIndent: 15),
                      ],
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

import 'package:flutter/material.dart';
import 'package:std/constants.dart';

class CategoryWidget extends StatelessWidget {
  final String? selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onChanged;

  const CategoryWidget({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: InputDecoration(
        hintText: '카테고리',
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.black),
        ),
      ),

      dropdownColor: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.black),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(
            category,
            style: const TextStyle(fontSize: 16, color: AppColors.black),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

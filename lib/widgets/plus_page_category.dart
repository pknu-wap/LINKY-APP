import 'package:flutter/material.dart';

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
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),

      dropdownColor: const Color(0xffFFFFFF),
      borderRadius: BorderRadius.circular(14),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(
            category,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryDropdown({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xffF0F2F6)),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return ListTile(
            visualDensity: VisualDensity.compact,
            title: Text(
              category,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isSelected ? const Color(0xff3fd966) : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check, color: Color(0xff3fd966), size: 20)
                : null,
            onTap: () => onCategorySelected(category),
          );
        },
      ),
    );
  }
}

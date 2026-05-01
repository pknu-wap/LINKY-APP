import 'package:flutter/material.dart';
import 'package:std/constants.dart';

// class CategoryWidget extends StatelessWidget {
//   final String? selectedCategory;
//   final List<String> categories;
//   final ValueChanged<String?> onChanged;

//   const CategoryWidget({
//     super.key,
//     required this.selectedCategory,
//     required this.categories,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonFormField<String>(
//       value: selectedCategory,
//       decoration: InputDecoration(
//         hintText: '카테고리',
//         filled: true,
//         fillColor: AppColors.white,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 18,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: AppColors.black),
//         ),
//       ),

//       dropdownColor: AppColors.white,
//       borderRadius: BorderRadius.circular(14),
//       icon: const Icon(Icons.arrow_drop_down, color: AppColors.black),
//       items: categories.map((category) {
//         return DropdownMenuItem<String>(
//           value: category,
//           child: Text(
//             category,
//             style: const TextStyle(fontSize: 16, color: AppColors.black),
//           ),
//         );
//       }).toList(),
//       onChanged: onChanged,
//     );
//   }
// }

class CategoryWidget extends StatefulWidget {
  // 상태 관리를 위해 StatefulWidget으로 변경
  const CategoryWidget({
    super.key,
    required this.onCategorySelected, // 값이 바뀌었을 때 실행할 콜백
    required this.categories,
  });

  final Function(String) onCategorySelected;
  final List<String> categories;

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),

        side: const BorderSide(
          color: AppColors.black, // 테두리 색상
          width: 0.5, // 테두리 두께
        ),
      ),

      offset: const Offset(13, 40),

      menuPadding: EdgeInsets.symmetric(vertical: 3),

      // 메뉴 전체의 최대 너비 제한
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 300,
        maxHeight: 250,
      ),

      onSelected: (value) {
        widget.onCategorySelected(value); // 부모에게 값 전달
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> menuList = [];
        for (int i = 0; i < widget.categories.length; i++) {
          menuList.add(
            PopupMenuItem<String>(
              padding: EdgeInsets.symmetric(horizontal: 40),
              value: widget.categories[i],
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  widget.categories[i],
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.mainBlue,
                  ),
                ),
              ),
            ),
          );
          if (i < widget.categories.length - 1) {
            menuList.add(const PopupMenuDivider(height: 1));
          }
        }
        return menuList;
      },
      child: const Icon(Icons.arrow_drop_down_outlined),
    );
  }
}

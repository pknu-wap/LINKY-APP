import 'package:flutter/material.dart';

class CategoryButton extends StatefulWidget {
  // 상태 관리를 위해 StatefulWidget으로 변경
  const CategoryButton({
    super.key,
    required this.onCategorySelected, // 값이 바뀌었을 때 실행할 콜백
    required this.categories,
  });

  final Function(String) onCategorySelected;
  final List<String> categories;

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),

        side: const BorderSide(
          color: Colors.black, // 테두리 색상
          width: 0.5, // 테두리 두께
        ),
      ),

      offset: const Offset(0, 40),

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
              padding: EdgeInsets.symmetric(horizontal: 60),
              value: widget.categories[i],
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  widget.categories[i],
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
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

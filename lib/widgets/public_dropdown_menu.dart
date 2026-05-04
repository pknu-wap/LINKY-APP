import 'package:flutter/material.dart';
import 'package:std/constants.dart';

class DropdownWidget extends StatefulWidget {
  const DropdownWidget({
    super.key,
    required this.onCategorySelected, // 값이 바뀌었을 때 실행할 콜백
    required this.itemsList,
    required this.menuWidget,
  });

  final Function(String) onCategorySelected;
  final List<String> itemsList;
  final Widget menuWidget;

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),

        side: const BorderSide(
          color: AppColors.black,
          width: 0.5,
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
        widget.onCategorySelected(value);
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> menuList = [];
        for (int i = 0; i < widget.itemsList.length; i++) {
          menuList.add(
            PopupMenuItem<String>(
              padding: EdgeInsets.symmetric(horizontal: 40),
              value: widget.itemsList[i],
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  widget.itemsList[i],
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.mainBlue,
                  ),
                ),
              ),
            ),
          );
          if (i < widget.itemsList.length - 1) {
            menuList.add(const PopupMenuDivider(height: 1));
          }
        }
        return menuList;
      },
      child: widget.menuWidget,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/constants.dart';

class SelectCategoryHome extends StatelessWidget {
  final String categoryTitle;
  final String categoryCount;
  final Color backgroundColor; // 전체 배경색
  final Color countBackgroundColor; // 왼쪽 개수 박스 배경색
  final Color textColor; // 텍스트 색상

  const SelectCategoryHome({
    super.key,
    required this.categoryTitle,
    required this.categoryCount,
    required this.backgroundColor,
    required this.countBackgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 높이는 기존 디자인에 맞춰 조절하세요
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor, // 전달받은 배경색 적용
        borderRadius: BorderRadius.circular(25),
        // 선택되지 않았을 때 심심하지 않게 아주 연한 테두리를 줄 수 있습니다.
        border: Border.all(color: AppColors.black),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: countBackgroundColor, // 전달받은 개수창 색상 적용 (#C5C5C5 등)
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              categoryCount,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            categoryTitle,
            style: GoogleFonts.inter(
              color: textColor, // 전달받은 글자색 적용
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

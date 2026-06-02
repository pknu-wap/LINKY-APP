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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.bottNavTextGrey.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        color: backgroundColor, 
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.black, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: countBackgroundColor,
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
              color: textColor,
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

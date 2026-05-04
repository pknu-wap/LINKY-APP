import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/constants.dart';

class SelectCategory extends StatelessWidget {
  final String categoryCount, categoryTitle;

  const SelectCategory({
    super.key,
    required this.categoryCount,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: AppColors.mainGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black),
      ),
      child: Row(
        children: [
          Container(
            alignment: Alignment(0, 0),
            margin: EdgeInsets.only(
              top: 4,
              right: 5,
              left: 4,
              bottom: 4,
            ),
            height: 27,
            width: 39,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: AppColors.white,
            ),
            child: SizedBox(
              width: 30,
              height: 19,
              child: Text(
                categoryCount,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 63,
            height: 19,
            child: Text(
              categoryTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

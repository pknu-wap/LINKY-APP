import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:std/constants.dart';
import 'package:std/widgets/plus_page_category.dart';

class EditContentSheet extends StatelessWidget {
  const EditContentSheet({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController urlController = TextEditingController();
    TextEditingController summaryController = TextEditingController();

    Size screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height * 0.9,
      width: screenSize.width,
      decoration: BoxDecoration(
        color: AppColors.popupBackGrey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleButton(
                Icons.close_rounded,
                AppColors.mainRed,
                () => Navigator.pop(context),
              ),
              _circleButton(
                Icons.check_rounded,
                AppColors.mainGreen,
                () => Navigator.pop(context),
              ),
            ],
          ),

          SizedBox(height: 23),

          _WhiteContainer(
            screenSize: screenSize,
            insideWidget: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "제목 수정",
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.cancel_outlined, color: AppColors.textGrey),
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: urlController,
                        decoration: InputDecoration(
                          hintText: "URL 수정",
                          border: InputBorder.none,
                          isDense: true,
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.cancel_outlined, color: AppColors.textGrey),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 23),

          _WhiteContainer(
            screenSize: screenSize,
            insideWidget: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '날짜 수정',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textGrey,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ),

          SizedBox(height: 23),

          _WhiteContainer(
            screenSize: screenSize,
            insideWidget: Row(
              children: [
                Expanded(
                  child: Text(
                    '카테고리 수정',
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                ),
                Icon(Icons.arrow_drop_down_sharp),
                // CategoryWidget(onCategorySelected: onCategorySelected, categories: categories) // 카테고리 선택
              ],
            ),
          ),

          SizedBox(height: 23),

          _WhiteContainer(
            screenSize: screenSize,
            insideWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '요약 수정',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                ),
                TextField(
                  controller: summaryController,
                  maxLines: 13,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(width: 0.33, color: AppColors.outlineGrey),
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 48,
          ),
        ),
      ),
    );
  }
}

class _WhiteContainer extends StatelessWidget {
  const _WhiteContainer({
    required this.screenSize,
    required this.insideWidget,
  });

  final Size screenSize;
  final Widget insideWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        color: AppColors.white,
      ),
      // height: 101,
      width: screenSize.width * 0.86,
      padding: EdgeInsets.symmetric(horizontal: 19, vertical: 14),
      child: insideWidget,
    );
  }
}
